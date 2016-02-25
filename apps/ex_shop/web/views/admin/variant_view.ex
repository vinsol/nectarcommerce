defmodule ExShop.Admin.VariantView do
  use ExShop.Web, :view
  import Ecto.Query

  def option_name([h|_]), do: option_name(h)
  def option_name([h]), do: option_name(h)
  def option_name(%ExShop.OptionValue{option_type: %ExShop.OptionType{presentation: presentation}}), do: presentation
end
