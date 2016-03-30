defmodule Nectar.Gateway do

  def authorize_payment(order, selected_payment_id, payment_method_params) do
    do_authorize_payment(order, selected_payment_method(selected_payment_id), payment_method_params)
  end

  defp selected_payment_method(selected_payment_id) do
    Nectar.Repo.get!(Nectar.PaymentMethod, selected_payment_id) |> Map.get(:name)
  end

  defp do_authorize_payment(order, method_name, params) do
    payment_module = Module.concat(Nectar.Gateway, (Macro.camelize method_name))
    apply(payment_module, :authorize, [order, params[method_name]])
  end
end
