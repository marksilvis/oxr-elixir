defmodule OXR do
  @moduledoc """
  A thin wrapper for the Open Exchange Rates API
  Requires an app id, which you can receive at https://openexchangerates.org
  """

  @url "https://openexchangerates.org/api"

  ## endpoints
  @latest "/latest.json"
  @historical "/historical"
  @currencies "/currencies.json"
  @time_series "/time-series.json"
  @convert "/convert"
  @usage "/usage.json"

  ## constants
  @date ~r/[0-9]{4}-[01][0-9]-[0-3][0-9]/

  ## messages
  @unknown "An unknown error has occurred"
  @invalid_date_format "Invalid date format\nMust match YYYY-MM-DD"
  
  @type timestamp :: pos_integer
  @type rate :: number
  @type rates :: %{String.t => rate}
  @type currencies :: %{String.t => String.t}
  @type converted :: number
  @type http_status :: 200..511
  @type error_message :: String.t
  @type error_description :: String.t

  @doc """
  Get latest exchange rates
  Default base is USD
  """
  @spec latest(String.t, String.t, [String.t, ...]) :: {:ok, timestamp, rates} | {:error, http_status, error_message, error_description} | {:error, error_description}
  def latest(app_id, base \\ "", symbols \\ []) do
    request = "#{@url}#{@latest}?app_id=#{app_id}"

    # set base parameter
    if base != nil && String.length(base) > 0 do
      request = request <> "&base=#{base}"
    end

    # set symbols parameter
    if symbols != nil && Enum.count(symbols) > 0 do
      request = request <> "&symbols=" <> Enum.join(symbols, ",")
    end

    # get response
    response = HTTPoison.get!(request)
    body = Poison.decode!(response.body)
    status = response.status_code

    # return rates
    cond do
      status === 200 ->
        {:ok, body["timestamp"], body["rates"]}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @doc """
  Get historical exchange rates for any date available
  Default base is USD
  """
  @spec historical(String.t, String.t, [String.t, ...]) :: {:ok, timestamp, rates} | {:error, http_status, error_message, error_description} | {:error, error_description}
  def historical(app_id, date, base \\ "", symbols \\ []) do
    # check for valid date format
    if !Regex.match?(@date, date) do
      raise @invalid_date_format
    end

    request = "#{@url}#{@historical}#{date}.json?app_id=#{app_id}"

    # set base parameter
    if base != nil && String.length(base) > 0 do
      request = request <> "&base=#{base}"
    end

    # set symbols parameter
    if symbols != nil && Enum.count(symbols) > 0 do
      request = request <> "&symbols=" <> Enum.join(symbols, ",")
    end

    # get response
    response = HTTPoison.get!(request)
    body = Poison.decode!(response.body)
    status = response.status_code

    # return historical data
    cond do
      status === 200 ->
        {:ok, body["timestamp"], body["rates"]}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @doc """
  Get all currencies available
  """
  @spec currencies(boolean) :: {:ok, currencies} | {:error, http_status, error_message, error_description} | {:error, error_description}
  def currencies(show_experimental \\ false) do
    request = "#{@url}#{@currencies}"
    
    # set show_experimental parameter
    if show_experimental do
      request = request <> "?show_experimental=1"
    end

    # get response
    response = HTTPoison.get!(request)
    body = Poison.decode!(response.body)
    status = response.status_code

    # return currencies
    cond do
      status === 200 -> 
        {:ok, body}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @doc """
  Get historical exchange rates for a given time period
  Default base is USD
  """
  @spec time_series(String.t, String.t, [String.t, ...], String.t, String.t) :: {:ok, rates} | {:error, http_status, error_message, error_description} | {:error, error_description}
  def time_series(app_id, start, stop,  base \\ "",symbols \\ []) do
    # check for valid date format
    if !(Regex.match?(@date, start) || Regex.match?(@date, stop)) do
      raise @invalid_date_format
    end

    request = "#{@url}#{@time_series}?app_id=#{app_id}&start=#{start}&end=#{stop}"

    # set base parameter
    if base != nil && String.length(base) > 0 do
      request = request <> "&base=#{base}"
    end

    # set symbols parameter
    if symbols != nil && Enum.count(symbols) > 0 do
      request = request <> "&symbols=" <> Enum.join(symbols, ",")
    end

    # get response
    response = HTTPoison.get!(request)
    body = Poison.decode!(response.body)
    status = response.status_code

    # return rates
    cond do
      status === 200 ->
        {:ok, body["rates"]}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @doc """
  Convert money value from one currency to another
  """
  @spec convert(String.t, number, String.t, String.t) :: {:ok, timestamp, rate, converted} | {:error, http_status, error_message, error_description} | {:error, error_description}
  def convert(app_id, value, from, to) do
    request = "#{@url}#{@convert}/#{value}/#{from}/#{to}?app_id=#{app_id}"

    # get response
    response = HTTPoison.get!(request)
    body = Poison.decode!(response.body)
    status = response.status_code

    # return converted currency
    cond do
      status == 200 ->
        timestamp = body["meta"]["timestamp"]
        rate = body["meta"]["rate"]
        converted = body["response"]
        {:ok, timestamp, rate, converted}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @doc """
  Get basic plan information and usage statistics
  Warning: this endpoint is still in beta
  """
  @spec usage(String.t) :: {:ok, %Data{}} | {:error, http_status, String.t, String.t} | {:error, String.t}
  def usage(app_id) do
    request = "#{@url}#{@usage}?app_id=#{app_id}"

    # get response
    response = HTTPoison.get!(request)
    body = response.body
    status = Poison.Parser.parse!(body) |> Map.get("status")

    # return usage data
    cond do
      status === 200 ->
        {:ok, get_usage_data(body)}
      status >= 300 ->
        {:error, status, body["message"], body["description"]}
      true ->
        {:error, @unknown}
    end
  end

  @spec get_usage_data(%{}) :: %Data{} 
  defp get_usage_data(body) do
    parsed = Poison.Parser.parse!(body) |> Map.get("data")
    plan = parsed["plan"]
    feat = plan["features"]
    usage = parsed["usage"]

    # return usage data
    %Data{app_id: parsed["app_id"], status: parsed["status"],
          plan: %Data.Plan{name: plan["name"], quota: plan["quota"], update_frequency: plan["update_frequency"],
            features: %Data.Plan.Features{base: feat["base"], symbols: feat["symbols"], experimental: feat["experimental"], time_series: feat["time-series"], convert: feat["convert"]}},
          usage: %Data.Usage{requests: usage["requests"], requests_quota: usage["requests_quota"], requests_remaining: usage["requests_remaining"], days_elapsed: usage["days_elapsed"], days_remaining: usage["days_remaining"], daily_average: usage["daily_average"]}}
  end
end
