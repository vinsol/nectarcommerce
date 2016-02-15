defmodule ExShop.Admin.CheckoutView do
	use ExShop.Web, :view

  alias ExShop.Repo
  import Ecto.Query

  def country_names_and_ids do
    Repo.all(from c in ExShop.Country, select: {c.name, c.id})
  end
  def state_names_and_ids do
    Repo.all(from c in ExShop.State, select: {c.name, c.id})
  end
end
