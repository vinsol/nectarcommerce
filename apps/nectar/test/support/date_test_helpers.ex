defmodule Nectar.DateTestHelpers do
  def get_past_date(days \\ 1),
    do: days_from_current_date(-1 * days)

  def get_future_date(days \\ 1),
    do: days_from_current_date(days)

  def get_current_date,
    do: Ecto.Date.utc

  defp days_from_current_date(days) do
    {:ok, date} = Ecto.Date.dump(Ecto.Date.utc)
    {:ok, next_date} = Ecto.Date.load(days_from_date(date, days))
    next_date
  end

  # helper method, use negative days to remove days from date
  defp days_from_date(date, days) do
    :calendar.date_to_gregorian_days(date) + days
    |> :calendar.gregorian_days_to_date
  end
end
