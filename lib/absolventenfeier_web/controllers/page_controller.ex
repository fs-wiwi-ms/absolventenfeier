defmodule AbsolventenfeierWeb.PageController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Uploads

  def index(conn, _params) do
    degrees = Uploads.get_degrees_for_select()
    render(conn, "index.html", degrees: degrees)
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
