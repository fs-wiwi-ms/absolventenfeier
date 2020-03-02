defmodule AbsolventenfeierWeb.Router do
  use AbsolventenfeierWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(AbsolventenfeierWeb.Authentication, type: :api_or_browser)
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

    resources "/events", EventController, only: [:index] do
      resources "/registrations", RegistrationController, only: [:new, :show]
    end

    resources "/registrations", RegistrationController, only: [:create]

    # get "/games/:id/scores", GameController, :show

    # resources "/games", GameController, only: [:index, :new, :create] do
    #   resources "/scores", ScoreController, only: [:new]
    #   get "/scores/:id/re_roll", ScoreController, :re_roll
    #   get "/scores/:id/finish", ScoreController, :finish
    #   post "/scores/:id/re_roll", ScoreController, :re_roll_score
    #   post "/scores/:id/finish", ScoreController, :finish_score
    # end

    # resources "/transactions", TransactionController, only: [:new, :create]

    resources "/sessions", SessionController, only: [:delete]
  end
end
