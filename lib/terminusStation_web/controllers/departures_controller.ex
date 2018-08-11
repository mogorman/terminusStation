defmodule TerminusStationWeb.DeparturesController do
  use TerminusStationWeb, :controller
  alias TerminusStation.Stations

  def departures(conn, _params) do
    {stationsText, rows} = Stations.get_board("\\n")
    render(conn, "departures.html", stationsText: stationsText, rows: rows)
  end

  def index(conn, _params) do
    north = %{name: "North Station", departures: Stations.get_by_station("place-north")}
    south = %{name: "South Station", departures: Stations.get_by_station("place-sstat")}
    render(conn, "index.html", stations: [north, south])
  end
end
