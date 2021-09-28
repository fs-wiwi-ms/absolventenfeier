defmodule AbsolventenfeierWeb.OrderController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.{User, Event}

  def new(conn, %{"event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()
      |> IO.inspect

    event = Event.get_event(event_id, [])

    registration = Event.user_registerd_for_event(event.id, user.id)

    case Event.get_event_state(event) do
      :ticketing_open ->

        render(conn, "new.html",
          user: user,
          event: event,
          registration: registration
        )

      _other ->
        conn
        |> put_flash(:error, gettext("Ticketing already closed!"))
        |> redirect(to: event_path(conn, :index))
    end
  end
end
