defmodule AbsolventenfeierWeb.Router do
  use AbsolventenfeierWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser, forward_to_login: false)
  end

  pipeline :protected_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser, forward_to_login: true)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through(:browser)

    get "/", PageController, :index
  end

  scope "/public", AbsolventenfeierWeb, as: :public do
    pipe_through(:browser)

    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create])
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through(:protected_browser)

    get "/events/:id/publish", EventController, :publish
    get "/events/:id/make_private", EventController, :make_private

    resources "/events", EventController, only: [:index, :new, :create, :edit, :update, :delete] do
      resources "/registrations", RegistrationController, only: [:index, :new]
      resources "/tickets", TicketController, only: [:new]
      resources "/orders", OrderController, only: [:index, :new]
    end

    resources "/registrations", RegistrationController, only: [:create, :delete]
    resources "/tickets", TicketController, only: [:edit, :create, :update, :delete]

    resources "/orders", OrderController, only: [:edit, :update, :create, :delete] do
      resources "/payments", PaymentController, only: [:new]
    end

    resources "/payments", PaymentController, only: [:show]

    resources "/sessions", SessionController, only: [:delete]
  end

  scope "/api", AbsolventenfeierWeb do
    post "/webhook", PaymentController, :webhook
  end
end
