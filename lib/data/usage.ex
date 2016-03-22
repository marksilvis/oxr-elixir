defmodule Data.Usage do
  defstruct [:requests, :requests_quota, :requests_remaining, :days_elapsed, :days_remaining, :daily_average]
end
