defmodule NectarWallet.LayoutView do
  use Nectar.Web, :view
  defdelegate render(template, assigns), to: Nectar.LayoutView
end
