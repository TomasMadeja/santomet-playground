defmodule SuckmisicWeb.PageController do
  use SuckmisicWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
