defmodule TimeSeries do
  @derive [Poison.Encoder]
  defstruct [:start_date, :end_date, :base, :rates]
end