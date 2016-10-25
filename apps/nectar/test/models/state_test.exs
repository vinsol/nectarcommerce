defmodule Nectar.StateTest do
  use Nectar.ModelCase

  alias Nectar.TestSetup
  alias Nectar.State

  test "changeset with valid attributes" do
    changeset = State.changeset(%State{}, TestSetup.State.valid_attrs)
    assert changeset.valid?
  end

  test "missing country_id makes changeset invalid" do
    {status, changeset} = State.changeset(%State{}, Map.delete(TestSetup.State.valid_attrs, :country_id)) |> Repo.insert
    assert status == :error
    refute changeset.valid?
    assert errors_on(changeset) == [country_id: "can't be blank"]
  end


  test "save with valid attributes but missing country in db" do
    {status, changeset} = State.changeset(%State{}, Nectar.TestSetup.State.valid_attrs) |> Repo.insert
    assert status == :error

    assert errors_on(changeset) == [country_id: "does not exist"]
  end

end
