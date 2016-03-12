defmodule ExShop.SearchOrder do
  use ExShop.Web, :model

  import Ecto.Query

  alias ExShop.Order

  defdelegate order_states, to: ExShop.Order, as: :states

  schema "abstract table:search_order" do
    field :state, :string, virtual: true
    field :email, :string, virtual: true
    field :name, :string, virtual: true
  end

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, ~w(), ~w(state))
  end

  def search(params) do
    Order
      |> search_state(params)
      |> search_user(params)
  end

  defp search_state(queryable, %{"state" => state}) when (is_nil(state) or state == "") do
    queryable
  end
  defp search_state(queryable, %{"state" => state}) do
    from o in queryable,
      where: o.state == ^state
  end
  defp search_state(queryable, params) do
    queryable
  end

  defp search_user_email(queryable, %{"email" => email}) when (is_nil(email) or email == "") do
    queryable
  end
  defp search_user_email(queryable, %{"email" => email}) do
    queryable |> where([_, u], ilike(u.email, ^("%#{email}%")))
  end
  defp search_user_email(queryable, params) do
    queryable
  end

  defp search_user_name(queryable, %{"name" => name}) when (is_nil(name) or name == "") do
    queryable
  end
  defp search_user_name(queryable, %{"name" => name}) do
    queryable |> where([_, u], ilike(u.name, ^("%#{name}%")))
  end
  defp search_user_name(queryable, params) do
    queryable
  end

  defp search_user(queryable, %{"email" => email, "name" => name}) when (is_nil(email) or email == "") and (is_nil(name) or name == "") do
    queryable
  end
  defp search_user(queryable, params) do
    q = from o in queryable,
      left_join: u in assoc(o, :user),
      where: o.user_id == u.id

    q |> search_user_email(params) |> search_user_name(params)
  end
end
