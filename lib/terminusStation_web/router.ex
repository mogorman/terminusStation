defmodule TerminusStationWeb.Router do
  use TerminusStationWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TerminusStationWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", DeparturesController, :index)
    get("/departures", DeparturesController, :departures)
  end

  # Other scopes may use custom stacks.
  # scope "/api", TerminusStationWeb do
  #   pipe_through :api
  # end
end
