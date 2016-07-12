defmodule Nectar.PaymentTest do
  use Nectar.ModelCase
  alias Nectar.Payment

  describe "fields" do
    fields =
      ~w(id order_id payment_method_id amount)a ++
      ~w(payment_state transaction_id)a ++ timestamps
    has_fields Payment, fields
  end

  describe "associations" do
    assocs =
      ~w(order payment_method)a
    has_associations Payment, assocs
  end
end
