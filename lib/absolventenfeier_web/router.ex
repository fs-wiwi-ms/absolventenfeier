defmodule AbsolventenfeierWeb.Router do
  use AbsolventenfeierWeb, :router

  pipeline :unsecure_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AbsolventenfeierWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser do
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser, forward_to_login: false)
  end

  pipeline :protected_browser do
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser, forward_to_login: true)
  end

  pipeline :admins_only do
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser, forward_to_login: true)
    plug(AbsolventenfeierWeb.AdminOnly)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through([:unsecure_browser, :browser])

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
  end

  scope "/public", AbsolventenfeierWeb, as: :public do
    pipe_through([:unsecure_browser, :browser])

    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create])

    resources(
      "/password_reset_tokens",
      PasswordResetTokenController,
      only: [:new, :create, :show, :update]
    )
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through([:unsecure_browser, :protected_browser])

    resources "/events", EventController, only: [:index] do
      resources "/registrations", RegistrationController, only: [:new]
    end

    resources "/registrations", RegistrationController, only: [:create, :delete]
    resources "/sessions", SessionController, only: [:delete]
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through([:unsecure_browser, :admins_only])
    get "/events/:id/publish", EventController, :publish
    get "/events/:id/make_private", EventController, :make_private
    get "/events/:id/archive", EventController, :archive

    get "/events/:event_id/tickets/:ticket_id/vouchers/batch_create",
        VoucherController,
        :batch_create

    get "/events/:event_id/vouchers/batch_pretix_sync", VoucherController, :batch_pretix_sync

    resources "/events", EventController, only: [:new, :create, :edit, :update, :delete] do
      resources "/registrations", RegistrationController, only: [:index]
      resources "/tickets", TicketController, only: [:new]
    end

    resources "/tickets", TicketController, only: [:edit, :create, :update, :delete]
  end
end
