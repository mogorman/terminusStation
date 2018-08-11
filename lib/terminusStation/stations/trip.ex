defmodule TerminusStation.Stations.Trip do

  use Ecto.Schema
  import Ecto.Changeset

  schema "trips" do
    field :trip_id, :string
    field :vehicle_id, :string
    field :route_id, :string
    field :block_id, :string
    field :last_prediction, :string
    field :destination, :string
  end

  def changeset(trip, params \\%{}) do
    trip
    |> cast(params, [:trip_id, :vehicle_id, :route_id, :destination, :block_id, :last_prediction])
  end
end
