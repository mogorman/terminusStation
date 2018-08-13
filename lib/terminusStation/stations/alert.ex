defmodule TerminusStation.Stations.Alert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alerts" do
    field(:alert_id, :string)
    field(:route_id, :string)
    field(:stop_id, :string)
    field(:trip_id, :string)
    field(:effect, :string)
  end

  def changeset(alert, params \\ %{}) do
    alert
    |> cast(params, [:alert_id, :trip_id, :route_id, :stop_id, :effect])
  end
end
