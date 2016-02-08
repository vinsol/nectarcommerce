defmodule Worldly.Country do
  defstruct name: "", alpha_3_code: "", alpha_2_code: "", has_regions: false, common_name: "", official_name: "", numeric_code: ""

  @countries_data_file_path "" |> Path.relative_to_cwd
                               |> Path.join("lib")
                               |> Path.join("data")
                               |> Path.join("world.yml")
                               |> Path.expand

  alias Worldly.Country
  alias Worldly.Region
  alias Worldly.Locale

  def with_name(name) do
    Enum.filter(all, fn(%Country{name: country_name}) -> country_name == name end)
  end

  def with_code(code) do
    Enum.filter(all, fn(%Country{alpha_2_code: country_code}) -> country_code == code end)
  end

  def all do
    load_country_data
  end


  defp load_country_data do
    # yamerl returns data in format [[{key, value}], ..]
    # need to convert them into dictionaries before loading
    # into the structs
    [country_data_list] = :yamerl_constr.file @countries_data_file_path, schema: :failsafe
    Enum.map(country_data_list, fn(country_data) ->
      build_country_struct(country_data)
    end)
  end

  defp build_country_struct(country_data) do
    country = struct(Country, Enum.map(country_data, fn({key, value}) ->
      {String.to_atom(to_string(key)), to_string(value)}
    end))
    %Country{country | has_regions: Region.exists? country} |> Locale.set_locale_data('country')
  end

end
