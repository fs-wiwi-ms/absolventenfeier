defmodule AbsolventenfeierWeb.EventController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.{Event, User}

  def index(conn, _params) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    events = Event.get_events_for_registration()
    render(conn, "index.html", %{events: events, user: user})
  end
end
