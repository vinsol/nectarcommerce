defmodule NectarWallet.WalletTest do
  use NectarWallet.ModelCase

  alias NectarWallet.Wallet

  @valid_attrs %{amount: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Wallet.changeset(%Wallet{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Wallet.changeset(%Wallet{}, @invalid_attrs)
    refute changeset.valid?
  end
end
