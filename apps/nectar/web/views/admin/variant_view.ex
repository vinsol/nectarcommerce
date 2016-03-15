defmodule Nectar.Admin.VariantView do
  use Nectar.Web, :view
  import Ecto.Query

  def option_name([h]), do: option_name(h)
  def option_name([h|_]), do: option_name(h)
  def option_name(%Nectar.OptionValue{option_type: %Nectar.OptionType{presentation: presentation}}), do: presentation

  def variant_options_text(variant) do
    if variant.is_master do
      ""
    else
      " (" <> (
        Enum.map(variant.option_values,
          fn(y) -> "#{y.option_type.presentation}:#{y.presentation}" end
        )
        |> Enum.join(", ")
      )
      <> ")"
    end
  end
end
