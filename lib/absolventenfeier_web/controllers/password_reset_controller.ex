defmodule AbsolventenfeierWeb.PasswordResetTokenController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Users.{PasswordResetToken, User}

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    if user = User.get_user_by_email(email) do
      PasswordResetToken.create_password_reset_token(user)
    end

    conn
    |> put_flash(:info, gettext("We have sent you a mail"))
    |> redirect(to: Routes.public_session_path(conn, :new))
  end

  def show(conn, %{"id" => token}) do
    case PasswordResetToken.get_valid_token(token) do
      nil ->
        conn
        |> put_flash(:error, gettext("Link is not valid"))
        |> redirect(to: "/")

      token ->
        changeset = User.create_user_changeset(token)

        render(conn, "show.html",
          token: token,
          changeset: changeset,
          action: Routes.public_password_reset_token_path(conn, :update, token)
        )
    end
  end

  def update(conn, %{"user" => user_params, "id" => token}) do
    token = PasswordResetToken.get_token(token)

    with %PasswordResetToken{} <- token,
         user = %User{} <- token.user,
         {:ok, _user} <- User.change_user_password(user, user_params),
         {:ok, _token} <- PasswordResetToken.delete_password_reset_token(token) do
      conn
      |> put_flash(:info, gettext("Password changed succesful"))
      |> redirect(to: Routes.public_session_path(conn, :new))
    else
      nil ->
        conn
        |> put_flash(:error, gettext("Link is not valid"))
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Could not update password."))
        |> render("show.html",
          token: token,
          changeset: changeset,
          action: Routes.public_password_reset_token_path(conn, :update, token)
        )
    end
  end
end
