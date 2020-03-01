defmodule AbsolventenfeierWeb.UserController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.User

  def index(conn, _params) do
    users = User.get_users()

    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => user_id}) do
    user = User.get_user(user_id)

    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    user_changeset = User.change_user()

    render(conn, "new.html",
      changeset: user_changeset,
      action: public_user_path(conn, :create)
    )
  end

  def create(conn, %{"user" => user}) do
    case User.create_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Created!")
        |> redirect(to: public_session_path(conn, :new))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Fehler beim erstellen!")
        |> render("new.html",
          changeset: changeset,
          action: public_user_path(conn, :create)
        )
    end
  end
end
