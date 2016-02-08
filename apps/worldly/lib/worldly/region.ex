defmodule Worldly.Region do
  defstruct type: "", code: "", parent_code: "", name: ""

  alias Worldly.Country
  alias Worldly.Locale
  alias Worldly.Region

  @region_data_files_path "" |> Path.relative_to_cwd
                             |> Path.join("lib")
                             |> Path.join("data")
                             |> Path.expand

  def exists?(model) do
    model
    |> region_file
    |> File.exists?
  end

  def regions_for(model) do
    region_file(model)
    |> load_region_data
    |> build_region_structs(model)
  end

  defp load_region_data(file) do
    [regions] = :yamerl_constr.file file, schema: :failsafe
    convert_to_tuple = fn({key, value}) -> {String.to_atom(to_string(key)), value} end
    Enum.map(regions, fn(region_doc) -> Enum.into(Enum.map(region_doc, convert_to_tuple), %{}) end)
  end

  defp build_region_structs(region_list, %Country{alpha_2_code: code}) do
    Enum.map(region_list, fn(region_map) -> %Region{struct(Region, region_map)| parent_code: code} |> Locale.set_locale_data('region') end)
  end

  defp region_file(%Country{alpha_2_code: code}) do
    @region_data_files_path
    |> Path.join("world")
    |> Path.join("#{code}.yml")
  end
  defp region_file(%Region{code: code, parent_code: parent_code}) do
    @region_data_files_path
    |> Path.join("world")
    |> Path.join(parent_code)
    |> Path.join(code)
  end

end
