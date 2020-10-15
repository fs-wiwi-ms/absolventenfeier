defmodule Absolventenfeier.User.Email do
  import Bamboo.Email
  import AbsolventenfeierWeb.Gettext

  @doc "Creates a new email for user with password_reset_url and password_reset_token"
  @spec password_reset_email(User.t(), Token.t()) :: Email.t()
  def password_reset_email(user, token) do
    mailer = Application.get_env(:absolventenfeier, :mailer)

    password_reset_url =
      AbsolventenfeierWeb.Router.Helpers.public_password_reset_token_path(
        AbsolventenfeierWeb.Endpoint,
        :show,
        token.token
      )

    new_email()
    |> to(user.email)
    |> from(Keyword.get(mailer, :from_address))
    |> subject(dgettext("email", "reset_password"))
    |> html_body(password_reset_url)
    |> text_body(password_reset_url)
  end
end
