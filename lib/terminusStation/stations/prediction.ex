defmodule TerminusStation.Stations.Prediction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "predictions" do
    field(:prediction_id, :string)
    field(:vehicle_id, :string)
    field(:trip_id, :string)
    field(:stop_id, :string)
    field(:schedule_id, :string)
    field(:route_id, :string)
    field(:status, :string)
    field(:schedule_relationship, :string)
    field(:departure_time, :utc_datetime)
  end

  def changeset(prediction, params \\ %{}) do
    prediction
    |> cast(params, [
      :prediction_id,
      :trip_id,
      :vehicle_id,
      :route_id,
      :stop_id,
      :schedule_id,
      :status,
      :schedule_relationship,
      :departure_time
    ])
  end
end
