defmodule TerminusStation.Stations.Vehicle do

  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :vehicle_id, :string
    field :label, :string
    field :route_id, :string
    field :trip_id, :string
  end

  def changeset(vehicle, params \\%{}) do
    vehicle
    |> cast(params, [:trip_id, :vehicle_id, :route_id, :label])
  end
end
