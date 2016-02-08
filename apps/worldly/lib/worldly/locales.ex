defmodule Worldly.Locale do

  alias Worldly.Country
  alias Worldly.Region

  @locales_folder_path "" |> Path.relative_to_cwd
                          |> Path.join("lib")
                          |> Path.join("data")
                          |> Path.join("locale")
                          |> Path.expand

  def set_locale_data(model, type, locale_name\\'en')

  def set_locale_data(region, 'region', locale_name) do
    local_map = get_locale_data(region, locale_name)
                |> Enum.map(fn({key, value}) -> {String.to_atom(to_string(key)), to_string(value)} end)
    struct(region, local_map)
  end
  def set_locale_data(country, 'country', locale_name) do
    local_map =
      get_locale_data(country, locale_name)
      |> Enum.map(fn({key, value}) ->
                    {String.to_atom(to_string(key)), to_string(value)}
                 end)
    struct(country, local_map)
  end

  defp get_locale_data(%Country{alpha_2_code: country_code}, locale_name) do
    country_code_cc = to_char_list(String.downcase country_code)
    [{^locale_name, [{'world', world_data}]}] = world_locale_file(locale_name) |> load_locale_data()
    [{^country_code_cc, country_locale_data}] = Enum.filter(world_data, fn({code, _}) -> code == country_code_cc end)
    country_locale_data
  end
  defp get_locale_data(%Region{code: locale_code, parent_code: country_code}, locale_name) do
    country_code_cc = to_char_list(String.downcase to_string(country_code))
    locale_code_cc  = to_char_list(String.downcase to_string(locale_code))
    [{^locale_name, [{'world', world_data}]}] = regional_locale_file_path(locale_name, country_code_cc) |> load_locale_data()
    [{^country_code_cc, locale_data}] = Enum.filter(world_data, fn({code, _}) -> code == country_code_cc end)
    [{^locale_code_cc, data_map}] = Enum.filter(locale_data, fn({code, _}) -> code == locale_code_cc end)
    data_map
  end

  defp locale_folder(locale_name) do
    @locales_folder_path
    |> Path.join(locale_name)
  end

  defp regional_locale_file_path(locale_name, country_code) do
    locale_folder(locale_name)
    |> Path.join("world")
    |> Path.join("#{country_code}.yml")
  end

  defp world_locale_file(locale_name) do
    locale_folder(locale_name) |> Path.join("world.yml")
  end

  defp load_locale_data(file) do
    [locale_data] = :yamerl_constr.file file, schema: :failsafe
    locale_data
  end

end
