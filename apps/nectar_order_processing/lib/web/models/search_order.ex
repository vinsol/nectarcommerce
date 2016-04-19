defmodule Nectar.SearchOrder do
  use NectarCore.Web, :model

  import Ecto.Query

  alias Nectar.Order

  defdelegate order_states, to: Nectar.Order, as: :states

  schema "abstract table:search_order" do
    field :state, :string, virtual: true
    field :email, :string, virtual: true
    field :name, :string, virtual: true
    field :payment_method, :string, virtual: true
    field :shipment_method, :string, virtual: true
    field :start_date, Ecto.Date, virtual: true
    field :end_date, Ecto.Date, virtual: true
  end

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, ~w(), ~w(state))
  end

  def search(params) do
    Order
      |> search_state(params)
      |> search_from_start_date(params)
      |> search_till_end_date(params)
      |> search_user(params)
      |> search_payment_method(params)
      |> search_shipment_method(params)
  end

  defp search_state(queryable, %{"state" => state}) when (is_nil(state) or state == "") do
    queryable
  end
  defp search_state(queryable, %{"state" => state}) do
    from o in queryable,
      where: o.state == ^state
  end
  defp search_state(queryable, _params) do
    queryable
  end

  defp search_from_start_date(queryable, %{"start_date" => start_date}) when (is_nil(start_date) or start_date == "") do
    queryable
  end
  defp search_from_start_date(queryable, %{"start_date" => start_date}) do
    start_datetime = Map.merge(start_date, %{"hour" => 0, "min" => 0, "sec" => 0})
    case Ecto.DateTime.cast(start_datetime) do
      :error -> queryable
      _ -> from o in queryable,
        where: o.inserted_at >= ^start_datetime
    end
  end
  defp search_from_start_date(queryable, _params) do
    queryable
  end

  defp search_till_end_date(queryable, %{"end_date" => end_date}) when (is_nil(end_date) or end_date == "") do
    queryable
  end
  defp search_till_end_date(queryable, %{"end_date" => end_date}) do
    end_datetime = Map.merge(end_date, %{"hour" => 23, "min" => 59, "sec" => 59})
    case Ecto.DateTime.cast(end_datetime) do
      :error -> queryable
      _ -> from o in queryable,
        where: o.inserted_at <= ^end_datetime
    end
  end
  defp search_till_end_date(queryable, _params) do
    queryable
  end

  defp search_user_email(queryable, %{"email" => email}) when (is_nil(email) or email == "") do
    queryable
  end
  defp search_user_email(queryable, %{"email" => email}) do
    queryable |> where([_, u], ilike(u.email, ^("%#{email}%")))
  end
  defp search_user_email(queryable, _params) do
    queryable
  end

  defp search_user_name(queryable, %{"name" => name}) when (is_nil(name) or name == "") do
    queryable
  end
  defp search_user_name(queryable, %{"name" => name}) do
    queryable |> where([_, u], ilike(u.name, ^("%#{name}%")))
  end
  defp search_user_name(queryable, _params) do
    queryable
  end

  defp search_user(queryable, %{"email" => email, "name" => name}) when (is_nil(email) or email == "") and (is_nil(name) or name == "") do
    queryable
  end
  defp search_user(queryable, params) do
    q = from o in queryable,
      join: u in assoc(o, :user)

    q |> search_user_email(params) |> search_user_name(params)
  end

  defp search_payment_method(queryable, %{"payment_method" => payment_method}) when (is_nil(payment_method) or payment_method == "") do
    queryable
  end
  defp search_payment_method(queryable, %{"payment_method" => payment_method}) do
    from o in queryable,
      join: p in assoc(o, :payment),
      where: p.payment_method_id == ^payment_method
  end
  defp search_payment_method(queryable, _params) do
    queryable
  end

  defp search_shipment_method(queryable, %{"shipment_method" => shipment_method}) when (is_nil(shipment_method) or shipment_method == "") do
    queryable
  end
  defp search_shipment_method(queryable, %{"shipment_method" => shipment_method}) do
    from o in queryable,
      join: p in assoc(o, :shipping),
      where: p.shipping_method_id == ^shipment_method
  end
  defp search_shipment_method(queryable, _params) do
    queryable
  end
end
