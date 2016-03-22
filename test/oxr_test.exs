defmodule OXRTest do
  use ExUnit.Case, async: true
  doctest OXR

  @app_id File.read!("APP_ID") |> String.strip

  test "latest rates" do
    {:ok, _, rates} = OXR.latest(@app_id)
    assert Enum.count(rates) > 0
  end

  test "currencies" do
    {:ok, currencies} = OXR.currencies()
    assert Enum.count(currencies) > 0
  end

  test "usage" do
    {:ok, data} = OXR.usage(@app_id)
    assert data.app_id === @app_id
  end
end
