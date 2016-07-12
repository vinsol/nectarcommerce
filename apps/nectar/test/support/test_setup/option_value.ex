defmodule Nectar.TestSetup.OptionValue do
  def valid_attrs, do: Nectar.TestSetup.OptionType.valid_attrs[:option_values] |> List.first
  def invalid_attrs, do: %{}
end
