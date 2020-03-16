defmodule AbsolventenfeierWeb.Router do
  use AbsolventenfeierWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected_browser_no_login do
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
    pipe_through(:protected_browser_no_login)

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
    end

    resources "/registrations", RegistrationController, only: [:create, :delete]

    resources "/sessions", SessionController, only: [:delete]
  end
end
