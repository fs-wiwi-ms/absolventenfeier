defmodule AbsolventenfeierWeb.RegistrationController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.{Event, User}

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)
    registrations = Event.get_registrations_for_user(user_id)
    render(conn, "index.html", registrations: registrations)
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def new(conn, %{"event_id" => event_id}) do
    event = Event.get_event(event_id)

    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    registration_changeset = Event.change_registration(%{"event" => event, "user" => user})

    render(conn, "new.html",
      user: user,
      event: event,
      degree_types: get_degree_types(),
      course_types: get_course_types(),
      changeset: registration_changeset,
      action: registration_path(conn, :create)
    )
  end

  def create(conn, %{"registration" => registration}) do
    case Event.create_registration(registration) do
      {:ok, _registration} ->
        conn
        |> put_flash(:info, gettext("Registration successful!"))
        |> redirect(to: event_path(conn, :index))

      {:already_registered, _registration} ->
        conn
        |> put_flash(:warning, gettext("Already Registered!"))
        |> redirect(to: event_path(conn, :index))

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
          action: registration_path(conn, :create)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    id
    |> Event.get_registration()
    |> Event.delete_registration()

    conn
    |> put_flash(:info, gettext("Registration deleted."))
    |> redirect(to: event_path(conn, :index))
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
