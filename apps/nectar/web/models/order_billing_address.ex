defmodule Nectar.OrderBillingAddress do
  use Nectar.Web, :model

  schema "order_billing_addresses" do
    belongs_to :order, Nectar.Order
    belongs_to :address, Nectar.Address

    # virtual fields to mimic address in case address needs to be built
    # currently no way to cast_assoc for belongs_to in ecto < 2.0
    # TODO: remove this after updating ecto
    field :address_line_1, :string, virtual: true
    field :address_line_2, :string, virtual: true
    field :state_id, :integer, virtual: true
    field :country_id, :integer, virtual: true

    timestamps
    extensions
  end

  def changeset(model, params \\ %{}) do
    if address_id_available? params do
      model
      |> cast(params, ~w(), ~w(order_id address_id))
    else
      cast_with_address_created_from_params(model, params)
    end
  end

  defp address_id_available?(%{"address_id" => _address_id}), do: true
  defp address_id_available?(_params), do: false

  defp cast_with_address_created_from_params(model, params) do
    case Nectar.Address.changeset(%Nectar.Address{}, params) |> Nectar.Repo.insert do
      {:ok, address} -> changeset(model, %{"address_id" => address.id})
      {:error, address_changeset} -> copy_errors_from_address_changeset(model, address_changeset, params)
    end
  end


  @address_fields ~w(address_line_1 address_line_2 state_id country_id)
  defp copy_errors_from_address_changeset(model, address_changeset, params) do
    changeset = model |> cast(params, ~w(), ~w())
    Enum.reduce(@address_fields, changeset, fn(field_name, changeset) ->
      atomized_field_name = String.to_atom(field_name)
      error = address_changeset.errors[atomized_field_name]
      if error do
        add_error(changeset, atomized_field_name, error)
      else
        changeset
      end
    end)
  end

end
