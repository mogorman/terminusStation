defmodule TerminusStation.Stations.Route do

  use Ecto.Schema
  import Ecto.Changeset

  schema "routes" do
    field :route_id, :string
    field :long_name, :string
    field :short_name, :string
    field :type, :integer
  end

  def changeset(route, params \\%{}) do
    route
    |> cast(params, [:route_id, :long_name, :short_name, :type])
  end
end
