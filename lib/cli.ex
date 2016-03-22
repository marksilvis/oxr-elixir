defmodule OXR.CLI do

  def main(args) do
  args
  |> parse_args
  |> process
  end

  def parse_args(args) do
    opts = OptionParser.parse(args, switches: [help: :boolean],
                                    aliases:  [h: :help])
    case opts do
    	# help
      {[help: true], _, _} ->
      	:help
      #currencies
      {[experimental: true], ["currencies"], []} ->
      	[:currencies, true]
      {[], ["currencies"], []} ->
      	[:currencies, false]
      # latest
      {[id: id, base: base, symbols: symbols], ["latest"], []} ->
      	[:latest, id, base, symbols]
      {[id: id, base: base], ["latest"], []} ->
      	[:latest, id, base, []]
      {[id: id, symbols: symbols], ["latest"], []} ->
      	[:latest, id, "", symbols]
      {[id: id], ["latest"], []} ->
      	[:latest, id, "", []]
      # historical
      {[id: id, date: date, base: base, symbols: symbols], ["historical"], []} ->
      	[:historical, id, date, base, symbols]
      {[id: id, date: date, base: base], ["historical"], []} ->
      	[:historical, id, date, base, []]
      {[id: id, date: date, symbols: symbols], ["historical"], []} ->
      	[:historical, id, date, "", symbols]
      {[id: id, date: date], ["historical"], []} ->
      	[:historical, id, date, "", []]
      # time series
      {[id: id, start: start, end: stop, base: base, symbols: symbols], ["timeseries"], []} ->
      	[:timeseries, id, start, stop, base, symbols]
      {[id: id, start: start, end: stop, base: base], ["timeseries"], []} ->
      	[:timeseries, id, start, stop, base, []]
      {[id: id, start: start, end: stop, symbols: symbols], ["timeseries"], []} ->
      	[:timeseries, id, start, stop, "", symbols]
      {[id: id, start: start, end: stop], ["timeseries"], []} ->
      	[:timeseries, id, start, stop, "", []]
      # convert
      {[id: id, value: value, from: from, to: to], ["convert"], []} ->
      	[:convert, id, value, from, to]
      # usage
      {[id: id], ["usage"], []} ->
      	[:usage, id]
      _ ->
      	:help
    end
  end

  def process(:help) do
    IO.puts """
    help
            show list of commands

    currencies
            show list of currencies
              --experimental    (optional) show experimental currencies

    latest
            get latest rates
              --id       (required) app id
              --base     (optional) base currency
              --symbols  (optional) limit results to specific currencies
    
    historical
           get rates on date
             --id       (required) app id
             --date     (required) requested date in YYYY-MM-DD format
             --base     (optional) base currency
             --symbols  (optional) limit results to specific currencies

    timeseries
           get rates for given time period
             --id       (required) app id
             --start    (required) time series start date in YYYY-MM-DD format
             --end      (required) time series end date in YYYY-MM-DD format
             --base     (optional) base currency
             --symbols  (recommended) limit results to specific currencies

    convert
           convert monetary value from one currency to another
             --id     (required) app id
             --value  (required) value to be converted
             --from   (required) base currency
             --to     (required) target currency

    usage
           get usage and plan information
    """
  end

  def process([:latest, app_id, base, symbols]) do
  	case OXR.latest(app_id, base, symbols) do
  		{:ok, timestamp, rates} ->
  			IO.puts("timestamp: #{timestamp}\nrates:")
  			print_map(rates)
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  def process([:historical, app_id, date, base, symbols]) do
  	case OXR.historical(app_id, date, base, symbols) do
  		{:ok, timestamp, rates} ->
  			IO.puts("timestamp: #{timestamp}\nrates:")
  			print_map(rates)
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  def process([:currencies, show_experimental]) do
  	case OXR.currencies(show_experimental) do
  		{:ok, currencies} -> 
  			IO.puts("currencies:")
  			print_map(currencies)
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  def process([:timeseries, app_id, start, stop, base, symbols]) do
  	case OXR.time_series(app_id, start, stop, base, symbols) do
  		{:ok, rates} ->
  			print_map(rates)
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  def process([:convert, app_id, value, from, to]) do
  	case OXR.convert(app_id, value, from, to) do
  		{:ok, timestamp, rate, converted} ->
  			IO.puts("timestamp: #{timestamp}")
  			IO.puts("rate: #{rate}")
  			IO.puts("converted value: #{converted}")
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  def process([:usage, app_id]) do
  	case OXR.usage(app_id) do
  		{:ok, usage} ->
  			print_data(usage)
  		{:error, _, message, description} ->
  			IO.puts("error: #{message}")
  			IO.puts("description: #{description}")
  		{:error, description} ->
  			IO.puts(description)
  	end
  end

  defp print_map(map) do
    map
    |> Map.to_list
    |> Enum.sort
    |> Enum.each(fn({k, v}) -> IO.puts "#{k}: #{v}" end)
  end

  defp print_data(data) do
  	IO.puts """
app_id: #{data.app_id}
status: #{data.status}
plan:
    name: #{data.plan.name}
    quota: #{data.plan.quota}
    update frequency: #{data.plan.update_frequency}
    features:
        base: #{data.plan.features.base}
        convert: #{data.plan.features.convert}
        experimental: #{data.plan.features.experimental}
        symbols: #{data.plan.features.symbols}
        time series: #{data.plan.features.time_series}
usage:
    daily average: #{data.usage.daily_average}
    days elapsed: #{data.usage.days_elapsed}
    days remaining: #{data.usage.days_remaining}
    requests: #{data.usage.requests}
    requests quota: #{data.usage.requests_quota}
    requests remaining: #{data.usage.requests_remaining}
	"""
  end
end  
