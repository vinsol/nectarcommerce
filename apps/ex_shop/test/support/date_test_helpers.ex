defmodule ExShop.DateTestHelpers do
  def get_past_date(days \\ 1) do
    {:ok, {y,m,d}} = Ecto.Date.dump(get_current_date)
    # Not safe as would fail on edge dates :(
    prev_day = d - days
    {:ok, prev_date} = Ecto.Date.load({y,m,prev_day})
    prev_date
  end

  def get_current_date do
    Ecto.Date.utc
  end

  def get_future_date(days \\ 1) do
    {:ok, {y,m,d}} = Ecto.Date.dump(get_current_date)
    # Not safe as would fail on edge dates :(
    next_day = d + days
    {:ok, next_date} = Ecto.Date.load({y,m,next_day})
    next_date
  end
end
