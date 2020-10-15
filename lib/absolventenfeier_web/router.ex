defmodule AbsolventenfeierWeb.Router do
  use AbsolventenfeierWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :unsecure_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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

    get "/events/:id/publish", EventController, :publish
    get "/events/:id/make_private", EventController, :make_private
    get "/events/:id/archive", EventController, :archive

    resources "/events", EventController, only: [:index, :new, :create, :edit, :update, :delete] do
      resources "/registrations", RegistrationController, only: [:index, :new]
      resources "/tickets", TicketController, only: [:new]
      resources "/orders", OrderController, only: [:index, :new]
    end

    resources "/registrations", RegistrationController, only: [:create, :delete]
    resources "/tickets", TicketController, only: [:edit, :create, :update, :delete]

    resources "/orders", OrderController, only: [:edit, :update, :create, :delete] do
      resources "/payments", PaymentController, only: [:new, :create]
      resources "/promotion_code", PromotionCodeController, only: [:create]
    end

    resources "/promotion_code", PromotionCodeController, only: [:delete]

    resources "/payments", PaymentController, only: [:show]

    resources "/sessions", SessionController, only: [:delete]
  end

  scope "/" do
    pipe_through([:unsecure_browser, :admins_only])
    live_dashboard "/dashboard"
  end

  scope "/api", AbsolventenfeierWeb do
    post "/webhook", PaymentController, :webhook
  end
end
