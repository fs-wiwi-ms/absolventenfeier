defmodule AbsolventenfeierWeb.EventController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Events.{Event, Term}
  alias Absolventenfeier.Users.{User}

  def index(conn, _params) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    events =
      case user.role do
        n when n in [:user, :mollie] ->
          Event.get_events_for_registration()

        :admin ->
          Event.get_events()
      end

    render(conn, "index.html", %{events: events, user: user})
  end

  def new(conn, _params) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        event_changeset = Event.change_event()

        render(conn, "new.html",
          terms: get_terms(),
          changeset: event_changeset,
          action: Routes.event_path(conn, :create)
        )

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    event = Event.get_event(id, :tickets)

    case user.role do
      :admin ->
        event_changeset =
          id
          |> Event.get_event([:tickets])
          |> Event.change_event(%{})

        render(conn, "edit.html",
          terms: get_terms(),
          changeset: event_changeset,
          action: Routes.event_path(conn, :update, id),
          event: event
        )

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def create(conn, %{"event" => event}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Event.create_event(event) do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Creating event successful!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, changeset} ->
            conn
            |> put_flash(:error, gettext("Error while creating event!"))
            |> render("new.html",
              terms: get_terms(),
              changeset: changeset,
              action: Routes.event_path(conn, :create)
            )
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "event" => event}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Event.update_event(id, event) do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Updating event successful!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, changeset} ->
            conn
            |> put_flash(:error, gettext("Error while updating event!"))
            |> render("edit.html",
              terms: get_terms(),
              changeset: changeset,
              action: Routes.event_path(conn, :update, id)
            )
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def publish(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Event.publish_event(id) do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Published event successful!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while publishing event!"))
            |> redirect(to: Routes.event_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def make_private(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Event.make_event_private(id) do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Event is now private!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while making event private!"))
            |> redirect(to: Routes.event_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def archive(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Event.archive(id) do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Event is now archived!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while archiving event!"))
            |> redirect(to: Routes.event_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        result =
          id
          |> Event.get_event()
          |> Event.delete_event()

        case result do
          {:ok, _event} ->
            conn
            |> put_flash(:info, gettext("Deleting event successful!"))
            |> redirect(to: Routes.event_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while deleting event!"))
            |> redirect(to: Routes.event_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  defp get_terms() do
    Enum.map(Term.get_terms(), fn term ->
      {"
      #{Gettext.dgettext(AbsolventenfeierWeb.Gettext, "enum", Atom.to_string(term.type))}
      #{term.year}", term.id}
    end)
  end
end
