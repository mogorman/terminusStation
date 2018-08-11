defmodule TerminusStation.Stations.Schedule do

  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :schedule_id, :string
    field :trip_id, :string
    field :stop_id, :string
    field :route_id, :string
    field :prediction_id, :string
    field :pickup_type, :integer
    field :departure_time, :utc_datetime
  end

  def changeset(schedule, params \\%{}) do
    schedule
    |> cast(params, [:schedule_id, :trip_id, :stop_id, :route_id, :prediction_id, :departure_time, :pickup_type])
  end
end
