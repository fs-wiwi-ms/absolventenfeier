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

    degree_types = DegreeType.__enum_map__()
    course_types = CourseType.__enum_map__()

    render(conn, "new.html",
      user: user,
      event: event,
      degree_types: degree_types,
      course_types: course_types,
      changeset: registration_changeset,
      action: registration_path(conn, :create)
    )
  end

  def create(conn, %{"registration" => registration}) do
    case Event.create_registration(registration) do
      {:ok, _registration} ->
        conn
        |> put_flash(:info, "Created!")
        |> redirect(to: event_path(conn, :index))

      {:already_registered, _registration} ->
        conn
        |> put_flash(:warning, "Already Registered!")
        |> redirect(to: event_path(conn, :index))

      {:error, changeset} ->
        event = Event.get_event(registration["event_id"])
        user =
          conn
          |> get_session(:user_id)
          |> User.get_user()


        conn
        |> put_flash(:error, "Fehler beim erstellen!")
        |> render("new.html",
          user: user,
          event: event,
          degree_types: DegreeType.__enum_map__(),
          course_types: CourseType.__enum_map__(),
          changeset: changeset,
          action: registration_path(conn, :create)
        )
    end
  end
end
