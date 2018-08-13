defmodule TerminusStation.Stations.Stop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stops" do
    field(:stop_id, :string)
    field(:name, :string)
    field(:platform_name, :string)
    field(:platform_code, :string)
    field(:parent, :string)
  end

  def changeset(stop, params \\ %{}) do
    stop
    |> cast(params, [:stop_id, :name, :platform_name, :platform_code, :parent])
  end
end
