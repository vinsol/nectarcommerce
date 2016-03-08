defmodule ExShop.TestSetup.OptionType do
  alias ExShop.Repo
  alias ExShop.OptionType

  @option_type_attrs %{
    name: "Color", # Can lead to intermittent issues failing unique validation
    presentation: "Color",
    option_values: [
      %{
        name: "Red",
        presentation: "Red"
      },
      %{
        name: "Green",
        presentation: "Green"
      }
    ]
  }

  def create_option_type do
    option_type_changeset = OptionType.changeset(%OptionType{}, @option_type_attrs)
    option_type = Repo.insert!(option_type_changeset)
      |> Repo.preload([:option_values])
  end
end
