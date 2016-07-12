defmodule Nectar.Payment do
  use Nectar.Web, :model

  alias __MODULE__

  schema "payments" do
    belongs_to :order, Nectar.Order
    belongs_to :payment_method, Nectar.PaymentMethod
    field :amount, :decimal
    field :payment_state, :string, default: "authorized"
    field :transaction_id

    timestamps
    extensions
  end

  @payment_states  ~w(authorized captured refunded)

  @required_fields ~w(payment_method_id amount payment_state)a
  @optional_fields ~w(transaction_id)a

  def authorized?(%Payment{payment_state: "authorized"}), do: true
  def authorized?(%Payment{}), do: false

  def captured?(%Payment{payment_state: "captured"}), do: true
  def captured?(%Payment{}), do: false

  def refunded?(%Payment{payment_state: "refunded"}), do: true
  def refunded?(%Payment{}), do: false

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  # TODO: can we add errors while payment authorisation here ??
  def applicable_payment_changeset(model, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end


  @required_fields ~w(payment_state)a
  @optional_fields ~w()a
  def capture_changeset(model) do
    model
    |> cast(%{"payment_state" => "captured"}, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @required_fields ~w(payment_state)a
  @optional_fields ~w()a
  def refund_changeset(model) do
    model
    |> cast(%{"payment_state" => "refunded"}, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Payment,
    where: p.order_id == ^order_id
  end

end
