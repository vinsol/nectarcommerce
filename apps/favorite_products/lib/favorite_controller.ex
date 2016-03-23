defmodule FavoriteProducts.FavoriteController do
  use Phoenix.Controller

  import Ecto
  import Ecto.Query, only: [from: 1, from: 2]

  import Phoenix.Router.Helpers
  import FavoriteProducts.Gettext

  def index(conn, _params) do
    html conn, """
     <html>
       <head>
          <title>Passing an Id</title>
       </head>
       <body>
         <p>You sent in id HARCODED!!</p>
       </body>
     </html>
    """
  end
end
