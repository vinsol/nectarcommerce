defmodule Nectar.Query.Variant do
  use Nectar.Query, model: Nectar.Variant

  def master_variants, do: from m in Nectar.Variant, where: m.is_master
  def not_master_variants, do: from m in Nectar.Variant, where: not(m.is_master), preload: [option_values: :option_type]
end
