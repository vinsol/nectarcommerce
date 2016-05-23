defmodule Nectar.TestSetup.PaymentMethod do
  alias Nectar.Repo

  @names ["cheque", "call with a card"]

  def create_payment_methods(names \\ @names, enabled \\ true)

  def create_payment_methods(names, enabled) when is_list(names) do
    Enum.map(names, fn (name) -> create_payment_methods(name, enabled) end)
  end

  def create_payment_methods(name, enabled) do
    Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: name, enabled: enabled}) |> Repo.insert!
  end

end
