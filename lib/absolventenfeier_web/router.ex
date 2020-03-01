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

  scope "/public", AbsolventenfeierWeb, as: :public do
    pipe_through(:browser)

    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create])
  end

  scope "/", AbsolventenfeierWeb do
    pipe_through(:protected_browser)

    get "/", GameController, :index

    resources "/users", UserController, only: [:index, :show]

    get "/games/:id/scores", GameController, :show

    resources "/games", GameController, only: [:index, :new, :create] do
      resources "/scores", ScoreController, only: [:new]
      get "/scores/:id/re_roll", ScoreController, :re_roll
      get "/scores/:id/finish", ScoreController, :finish
      post "/scores/:id/re_roll", ScoreController, :re_roll_score
      post "/scores/:id/finish", ScoreController, :finish_score
    end

    resources "/transactions", TransactionController, only: [:new, :create]

    resources "/sessions", SessionController, only: [:delete]
  end

  scope "/api", AbsolventenfeierWeb do
    pipe_through :api

    get "/scheduler/next_round", SchedulerController, :next_round
    get "/scheduler/server_age", SchedulerController, :server_age
    post "/scheduler/cancel_block_propose", SchedulerController, :cancel_block_propose
    post "/scheduler/cancel_block_commit", SchedulerController, :cancel_block_commit

    get "/servers/this", ServerController, :this
    post "/servers/roll", ServerController, :roll
    resources "/servers", ServerController, only: [:index, :show, :create]

    resources "/users", UserController, only: [:index, :show, :create]

    resources "/transactions", TransactionController, only: [:index, :show, :create]

    post "/blocks/propose", BlockController, :propose
    post "/blocks/commit", BlockController, :commit
    post "/blocks/finalize", BlockController, :finalize
    get "/blocks/height", BlockController, :height
    resources "/blocks", BlockController, only: [:index, :show, :create]
  end
end
