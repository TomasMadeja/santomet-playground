defmodule SuckmisicWeb.Router do
  use SuckmisicWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SuckmisicWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", SuckmisicWeb do
    pipe_through :api

    post "/register", SyncController, :register
    post "/work/request", SyncController, :request
    post "/work/done", SyncController, :done
    post "/status/work", SyncController, :is_working
    post "/status/wait", SyncController, :is_waiting

    post "/node/spawn", NodeController, :spawn
    post "/node/terminate", NodeController, :terminate
    post "/node/exists", NodeController, :exists
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SuckmisicWeb.Telemetry
    end
  end
end
