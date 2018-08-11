defmodule TerminusStation.Stations do
  @moduledoc """
  Context for stations
  """
  require Logger
  import Ecto.Query
  alias TerminusStation.Repo
  alias TerminusStation.Stations.Route
  alias TerminusStation.Stations.Schedule
  alias TerminusStation.Stations.Trip
  alias TerminusStation.Stations.Stop
  alias TerminusStation.Stations.Vehicle
  alias TerminusStation.Stations.Alert
  alias TerminusStation.Stations.Prediction

####################################################################
# PRIVATE FUNCTIONS
  defp getTable(table) do
    mapping = %{ "route" => Route,
		 "schedule" => Schedule,
		 "prediction" => Prediction,
		 "stop" => Stop,
		 "trip" => Trip,
		 "alert" => Alert,
		 "vehicle" => Vehicle}
    Map.get(mapping,table)
  end

  defp getColumn(table) do
    mapping = %{ "route" => :route_id,
		 "schedule" => :schedule_id,
		 "prediction" => :prediction_id,
		 "stop" => :stop_id,
		 "trip" => :trip_id,
		 "alert" => :alert_id,
		 "vehicle" => :vehicle_id}
    Map.get(mapping,table)
  end

defp format_route(nil, _newline) do
  ""
end
defp format_route(route, newline) do
  List.to_string(:io_lib.format("~-12s", [route.destination])) <>
  List.to_string(:io_lib.format("~6s", [route.departure])) <>
  List.to_string(:io_lib.format(" ~4s", [route.train])) <>
  List.to_string(:io_lib.format(" ~-12s", [route.status])) <>
  List.to_string(:io_lib.format(" ~-4s", [route.track_code])) <> newline
  # route.railType <> " " <> route.time <> " " <>
  #   route.destination <> " " <> route.trainNumber <> " " <>
  #   route.trackNumber<> " "<> route.status <>"\\n"
end

defp format_station(nil, _newline) do
  ""
end
defp format_station(station, newline) do
  legend = "destination  time  trn  status     track"
#  legend = "rail time     dest        t#  trk status"
  station.name <> " departures" <> newline <> legend <> newline<> List.to_string(for route <- station.routes, do: format_route(route, newline))
end

defp map_no_nil(map, type) do
  newMap = Map.get(map,type,nil)
  if newMap, do: newMap, else: %{}
end

####################################################################

def get_alerts(scheduleId) do
  alerts = Repo.all(
    from(
      schedule in Schedule,
      left_join: alert in Alert,
      on: schedule.trip_id == alert.trip_id or schedule.stop_id == alert.stop_id or schedule.trip_id == alert.trip_id,
      where: schedule.schedule_id == ^scheduleId,
      order_by: schedule.departure_time,
      select: %{
  	effect: alert.effect
      }
    )
  )
  if (alerts == [%{effect: nil}]) do
    []
  else
    for alert <- alerts, do: alert.effect
  end

end
def get_by_station(station) do
  stations = Repo.all(
    from(
      schedule in Schedule,
      left_join: trip in Trip,
      on: schedule.trip_id == trip.trip_id,
      left_join: prediction in Prediction,
      on: schedule.trip_id == prediction.trip_id,
      left_join: vehicle in Vehicle,
      on: trip.trip_id == vehicle.trip_id,
      inner_join: stop in Stop,
      on: stop.stop_id == schedule.stop_id and stop.parent == ^station,
      inner_join: route in Route,
      on: route.route_id == schedule.route_id and route.type == 2,
#      where: schedule.departure_time >= ^Ecto.DateTime.to_string(Ecto.DateTime.utc()) and schedule.pickup_type == 0,
      where: schedule.departure_time >= datetime_add(^Ecto.DateTime.to_string(Ecto.DateTime.utc()), unquote("-5"), unquote("minute")) and schedule.pickup_type == 0,
      order_by: schedule.departure_time,
      select: %{
	railType: "Commuter",
	departure: schedule.departure_time,
	prediction_departure: prediction.departure_time,
	destination: trip.destination,
	train: vehicle.label,
	track_name: stop.platform_name,
	track_code: stop.platform_code,
	status: prediction.status,
	status_extra: prediction.schedule_relationship,
	station: stop.parent,
	schedule_id: schedule.schedule_id,
	alerts: []
      },
      limit: 10
    )
  )
  #Goofy way of converting stored utc data back to etc/d
  for station <- stations do
    train = if (station.train == nil), do: "", else: station.train
    track_code = if (station.track_code == nil), do: "TBD", else: station.track_code
    status = if (station.status == nil), do: "no data", else: station.status
    departure = station.departure |> Timex.Timezone.convert("America/New_York") |> Timex.format!("%H:%M", :strftime)
    prediction_departure = station.departure |> Timex.Timezone.convert("America/New_York") |> Timex.format!("%H:%M", :strftime)
    %{station |
      departure: departure,
      prediction_departure: prediction_departure,
      alerts: get_alerts(station.schedule_id),
      train: train,
      track_code: track_code,
      status: status
    }
  end
end

def get_board(newline) do
  northText = format_station(%{name: "North Station", routes: get_by_station("place-north")}, newline)
  southText = format_station(%{name: "South Station", routes: get_by_station("place-sstat")}, newline)
  rowCount = 24
  rows = Enum.to_list(1..if (rowCount == 0), do: 1, else: rowCount)
  {northText <> southText, rows}
end
def create_board(_board) do
  # Repo.delete_all(Board)
  # board
  # |> Repo.insert()
  nil
end

#if the output would be the same do nothing
def update_board(boardString, boardString) do
  boardString
end

def update_board(new, _old) do
  TerminusStationWeb.Endpoint.broadcast("route:lobby", "update", %{body: new})
  new
end


def update_board(boardString) do
  {board, _rows} = get_board("\n")
  update_board(board,boardString)
end

def drop_most() do
  Repo.delete_all(Schedule)
  Repo.delete_all(Trip)
  Repo.delete_all(Route)
  Repo.delete_all(Stop)
end

def drop_alerts() do
  Repo.delete_all(Alert)
end

def drop_predictions() do
  Repo.delete_all(Vehicle)
  Repo.delete_all(Prediction)
end

def remove(_data, type, id) do
  table = getTable(type)
  column = getColumn(type)
  case   Repo.get_by(table, %{column => id}) do
    nil -> nil
    record -> Repo.delete record # don't remove because it seems my predictions are getting deleted when i still want them
  end
end

def update(data, _from, "schedule", id) do
  record = case from(r in Schedule) |> where([r], r.schedule_id == ^id) |> Repo.one() do
	     nil -> %Schedule{}
	     record -> record
	   end
  departureTime = data |> map_no_nil("attributes") |> Map.get("departure_time", Map.get(record, :departure_time, ""))
  record
  |> Schedule.changeset(
    %{schedule_id: id,
      trip_id: data |> map_no_nil("relationships") |> map_no_nil("trip") |> map_no_nil("data") |> Map.get("id", Map.get(record, :trip_id, nil)),
      stop_id: data |> map_no_nil("relationships") |> map_no_nil("stop") |> map_no_nil("data") |> Map.get("id", Map.get(record, :stop_id, nil)),
      route_id: data |> map_no_nil("relationships") |> map_no_nil("route") |> map_no_nil("data") |> Map.get("id", Map.get(record, :route_id, nil)),
      prediction_id: data |> map_no_nil("relationships") |> map_no_nil("prediction") |> map_no_nil("data") |> Map.get("id", Map.get(record, :prediction_id, nil)),
      pickup_type: data |> map_no_nil("attributes") |> Map.get("pickup_type", Map.get(record, :pickup_type, nil)),
      departure_time: departureTime
    })
  |> Repo.insert_or_update
end
def update(data, _from, "trip", id) do
  record = case from(r in Trip) |> where([r], r.trip_id == ^id) |> Repo.one() do
	     nil -> %Trip{}
	     record -> record
	   end
  record
  |> Trip.changeset(%{trip_id: id,
		     vehicle_id: data |> map_no_nil("relationships") |> map_no_nil("vehicle") |> map_no_nil("data") |> Map.get("id", Map.get(record, :vehicle_id, nil)),
		     route_id: data |> map_no_nil("relationships") |> map_no_nil("route") |> map_no_nil("data") |> Map.get("id", Map.get(record, :route_id, nil)),
		     block_id: data |> map_no_nil("attributes") |> Map.get("block_id", Map.get(record, :block_id, nil)),
		     destination: data |> map_no_nil("attributes") |> Map.get("headsign", Map.get(record, :destination, nil))
		     })
		     |> Repo.insert_or_update
end
def update(data, _from, "route", id) do
  record = case from(r in Route) |> where([r], r.route_id == ^id) |> Repo.one() do
	     nil -> %Route{}
	     record -> record
	   end
  record
  |> Route.changeset(%{route_id: id,
		     long_name: data |> map_no_nil("attributes") |> Map.get("long_name", Map.get(record, :long_name, nil)),
		     short_name: data |> map_no_nil("attributes") |> Map.get("short_name", Map.get(record, :short_name, nil)),
		     type: data |> map_no_nil("attributes") |> Map.get("type", Map.get(record, :type, nil))})
		     |> Repo.insert_or_update
end
def update(data, _from, "stop", id) do
  record = case from(r in Stop) |> where([r], r.stop_id == ^id) |> Repo.one() do
	     nil -> %Stop{}
	     record -> record
	   end
  record
  |> Stop.changeset(%{stop_id: id,
		     name: data |> map_no_nil("attributes") |> Map.get("name", nil),
		     platform_name: data |> map_no_nil("attributes") |> Map.get("platform_name", Map.get(record, :platform_name, nil)),
		     platform_code: data |> map_no_nil("attributes") |> Map.get("platform_code", Map.get(record, :platform_code, nil)),
		     parent: data |> map_no_nil("relationships") |> map_no_nil("parent_station") |> map_no_nil("data") |> Map.get("id", Map.get(record, :parent, nil))})
		     |> Repo.insert_or_update
end
def update(data, _from, "vehicle", id) do
  record = case from(r in Vehicle) |> where([r], r.vehicle_id == ^id) |> Repo.one() do
	     nil -> %Vehicle{}
	     record -> record
	   end
  record
  |> Vehicle.changeset(%{
	vehicle_id: id,
	label: data |> map_no_nil("attributes") |> Map.get("label", Map.get(record, :label, nil)),
	route_id: data |> map_no_nil("relationships") |> map_no_nil("route") |> map_no_nil("data") |> Map.get("id", Map.get(record, :route_id, nil)),
	trip_id: data |> map_no_nil("relationships") |> map_no_nil("trip") |> map_no_nil("data") |> Map.get("id", Map.get(record, :trip_id, nil))
	})
  |> Repo.insert_or_update
end
def update(data, from, "prediction", id) do
  record = case from(r in Prediction) |> where([r], r.prediction_id == ^id) |> Repo.one() do
	     nil -> %Prediction{}
	     record -> record
	   end
  departureTime = data |> map_no_nil("attributes") |> Map.get("departure_time", Map.get(record, :departure_time, ""))
  tripId = data |> map_no_nil("relationships") |> map_no_nil("trip") |> map_no_nil("data") |> Map.get("id", Map.get(record, :trip_id, nil))
  status = data |> map_no_nil("attributes") |> Map.get("status", Map.get(record, :status, nil))
  if status != nil and tripId != nil do
    update(%{last_prediction: status}, from, "trip", tripId)
  end
  record
  |> Prediction.changeset(%{
	prediction_id: id,
	label: data |> map_no_nil("attributes") |> Map.get("label", Map.get(record, :label, nil)),
	vehicle_id: data |> map_no_nil("relationships") |> map_no_nil("vehicle") |> map_no_nil("data") |> Map.get("id", Map.get(record, :vehicle_id, nil)),
	stop_id: data |> map_no_nil("relationships") |> map_no_nil("stop") |> map_no_nil("data") |> Map.get("id", Map.get(record, :stop_id, nil)),
	route_id: data |> map_no_nil("relationships") |> map_no_nil("route") |> map_no_nil("data") |> Map.get("id", Map.get(record, :route_id, nil)),
	trip_id: tripId,
	status: status,
	schedule_relationship: data |> map_no_nil("attributes") |> Map.get("schedule_relationship", Map.get(record, :schedule_relationship, nil)),
	departure_time: departureTime
	})
  |> Repo.insert_or_update
end
def update(data, _from, "alert", id) do
  record = case from(r in Alert) |> where([r], r.alert_id == ^id) |> Repo.one() do
	     nil -> %Alert{}
	     record -> record
	   end
  record
  |> Alert.changeset(%{
	alert_id: id,
	route_id: data |> map_no_nil("attributes") |> map_no_nil("informed_entity") |> List.first |> Map.get("route", Map.get(record, :route_id, nil)),
	trip_id: data |> map_no_nil("attributes") |> map_no_nil("informed_entity") |> List.first |> Map.get("trip", Map.get(record, :trip_id, nil)),
	stop_id: data |> map_no_nil("attributes") |> map_no_nil("informed_entity") |> List.first |> Map.get("stop", Map.get(record, :stop_id, nil)),
	effect: data |> map_no_nil("attributes") |> Map.get("effect", Map.get(record, :effect, nil))
	})
  |> Repo.insert_or_update
end
def update(_data, _from, _type, _id) do
  nil
end
end
