defmodule AbsolventenfeierWeb.PageController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Uploads

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
