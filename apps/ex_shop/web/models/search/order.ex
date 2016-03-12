defmodule ExShop.SearchOrder do
  use ExShop.Web, :model

  alias ExShop.Order

  defdelegate order_states, to: ExShop.Order, as: :states

  schema "abstract table:search_order" do
    field :state, :string, virtual: true
    field :email, :string, virtual: true
  end

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, ~w(), ~w(state))
  end

  def search(params) do
    Order
      |> search_state(params)
      |> search_user_email(params)
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
    from o in queryable,
      left_join: u in assoc(o, :user),
      where: ilike(u.email, ^("%#{email}%")),
      where: o.user_id == u.id
  end
  defp search_user_email(queryable, params) do
    queryable
  end
end
