defmodule Nectar.Command.ZoneMemberTest do
  use Nectar.ModelCase

  describe "insert_for_zone/3" do
    test "inserts member into the zone" do
      zone = Nectar.TestSetup.Zone.create!
      country = Nectar.TestSetup.Country.create_country!
      {status, member} =
        Nectar.Command.ZoneMember.insert_for_zone(Nectar.Repo, country, zone)

      assert status == :ok
      assert member.id
      assert Nectar.Query.Zone.members(Nectar.Repo, zone) == [member]
    end
  end
end
