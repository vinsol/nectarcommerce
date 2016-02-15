defmodule ExShop.Tax do
  use ExShop.Web, :model

  schema "taxes" do
    field :name

    timestamps
  end

end
