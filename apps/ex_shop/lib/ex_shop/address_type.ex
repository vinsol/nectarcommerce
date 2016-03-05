defmodule ExShop.AddressType do
  @behaviour Ecto.Type

  def type, do: :integer

  @address_types %{
    "shipping" => 1,
    "billing"  => 2
  }

  def cast(string) when is_binary(string) do
    case Map.get(@address_types, string) do
      {int}
    end
  end

end
