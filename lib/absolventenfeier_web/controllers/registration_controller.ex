defmodule AbsolventenfeierWeb.RegistrationController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Events.{Event, Registration}
  alias Absolventenfeier.Users.{User}

  def index(conn, %{"event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        registrations = Registration.get_registrations_for_event(event_id)
        count = Enum.count(registrations)
        render(conn, "index.html", registrations: registrations, count: count)

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def new(conn, %{"event_id" => event_id}) do
    event = Event.get_event(event_id)

    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case Event.get_event_state(event) do
      :registration_open ->
        registration_changeset =
          Registration.change_registration(%{"event" => event, "user" => user})

        render(conn, "new.html",
          user: user,
          event: event,
          degree_types: get_degree_types(),
          course_types: get_course_types(),
          changeset: registration_changeset,
          action: Routes.registration_path(conn, :create)
        )

      :private ->
        conn
        |> put_flash(:error, gettext("Event is still private!"))
        |> redirect(to: Routes.event_path(conn, :index))

      _other ->
        conn
        |> put_flash(:error, gettext("Registration closed!"))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def create(conn, %{"registration" => registration}) do
    case Registration.create_registration(registration) do
      {:ok, _registration} ->
        conn
        |> put_flash(:info, gettext("Registration successful!"))
        |> redirect(to: Routes.event_path(conn, :index))

      {:already_registered, _registration} ->
        conn
        |> put_flash(:warning, gettext("Already Registered!"))
        |> redirect(to: Routes.event_path(conn, :index))

      {:error, changeset} ->
        event = Event.get_event(registration["event_id"])

        user =
          conn
          |> get_session(:user_id)
          |> User.get_user()

        conn
        |> put_flash(:error, gettext("Error while creating registration!"))
        |> render("new.html",
          user: user,
          event: event,
          degree_types: get_degree_types(),
          course_types: get_course_types(),
          changeset: changeset,
          action: Routes.registration_path(conn, :create)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    registration = Registration.get_registration(id)

    case Event.get_event_state(registration.event) do
      :registration_open ->
        Registration.delete_registration(registration)

        conn
        |> put_flash(:info, gettext("Registration deleted."))
        |> redirect(to: Routes.event_path(conn, :index))

      _other ->
        conn
        |> put_flash(:warning, gettext("Registration already closed."))
        |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  defp get_degree_types() do
    Enum.map(DegreeType.__enum_map__() -- [:none], fn enum ->
      {Gettext.dgettext(AbsolventenfeierWeb.Gettext, "enum", Atom.to_string(enum), %{}), enum}
    end)
  end

  defp get_course_types() do
    Enum.map(CourseType.__enum_map__() -- [:none], fn enum ->
      {Gettext.dgettext(AbsolventenfeierWeb.Gettext, "enum", Atom.to_string(enum)), enum}
    end)
  end
end
