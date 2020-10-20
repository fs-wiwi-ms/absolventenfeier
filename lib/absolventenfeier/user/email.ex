defmodule Absolventenfeier.User.Email do
  import Bamboo.Email
  import AbsolventenfeierWeb.Gettext

  @doc "Creates a new email for user with password_reset_url and password_reset_token"
  @spec password_reset_email(User.t(), Token.t()) :: Email.t()
  def password_reset_email(user, token) do
    password_reset_url =
      AbsolventenfeierWeb.Router.Helpers.public_password_reset_token_path(
        AbsolventenfeierWeb.Endpoint,
        :show,
        token.token
      )

    new_email()
    |> to(user.email)
    |> from(System.get_env("SMTP_FROM_ADDRESS"))
    |> subject(dgettext("email", "reset_password"))
    |> html_body(System.get_env("HOST") <> password_reset_url)
    |> text_body(System.get_env("HOST") <> password_reset_url)
  end
end
