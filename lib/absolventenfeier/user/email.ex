defmodule Absolventenfeier.User.Email do
  import Bamboo.Email
  import AbsolventenfeierWeb.Gettext

  alias Absolventenfeier.{Mailer}

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

  def deliver_now(email) do
    # if Mix.env() == :prod do
    #   smtp_host =
    #     System.get_env("SMTP_HOST") ||
    #       raise """
    #       environment variable SMTP_HOST is missing.
    #       """

    #   smtp_user_name =
    #     System.get_env("SMTP_USER_NAME") ||
    #       raise """
    #       environment variable SMTP_USER_NAME is missing.
    #       """

    #   smtp_password =
    #     System.get_env("SMTP_PASSWORD") ||
    #       raise """
    #       environment variable SMTP_PASSWORD is missing.
    #       """

    #   smtp_port =
    #     System.get_env("SMTP_PORT") ||
    #       raise """
    #       environment variable SMTP_PORT is missing.
    #       """

    #   Mailer.deliver_now(email,
    #     server: smtp_host,
    #     hostname: host,
    #     port: smtp_port,
    #     username: smtp_user_name,
    #     password: smtp_password,
    #     ssl: true,
    #     tls: :always,
    #     auth: :always
    #   )
    # else
      Mailer.deliver_now(email)
    # end
  end
end
