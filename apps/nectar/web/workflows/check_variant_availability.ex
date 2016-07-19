defmodule Nectar.Workflow.CheckVariantAvailability do
  alias Ecto.Multi

  def steps(variant, quantity, changeset) do
    Multi.new()
    |> Multi.run(:availability, &(ensure_variant_available(&1, variant, quantity, changeset)))
  end

  defp ensure_variant_available(_changes, variant, quantity, changeset) do
    cond do
      Nectar.Variant.discontinued?(variant) ->
        {:error, Ecto.Changeset.add_error(changeset, :variant, "has been discontinued")}
      not Nectar.Variant.sufficient_quantity_available?(variant, quantity) ->
        available = Nectar.Variant.available_quantity(variant)
        if available > 0 do
          {:error, Ecto.Changeset.add_error(changeset, :quantity, "only #{ available } available")}
        else
          {:error, Ecto.Changeset.add_error(changeset, :variant, "out of stock")}
        end
      true ->
        {:ok, true}
    end
  end


end
