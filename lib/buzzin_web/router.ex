defmodule BuzzinWeb.Router do
  use BuzzinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BuzzinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BuzzinWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/register", UserController, :register_page
    get "/login", UserController, :login_page
    get "/chat", ChatController, :index
  end

  scope "/api", BuzzinWeb do
    pipe_through :api

    post "/register", UserController, :register
    post "/login", UserController, :login

    get "/conversations", MessageController, :conversations
    get "/messages/:other_user_id", MessageController, :index
    post "/messages", MessageController, :create

  end

  # Other scopes may use custom stacks.
  # scope "/api", BuzzinWeb do
  #   pipe_through :api
  # end
end
