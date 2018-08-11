defmodule TerminusStation.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :schedule_id, :string
      add :trip_id, :string
      add :stop_id, :string
      add :route_id, :string
      add :prediction_id, :string
      add :departure_time, :utc_datetime
      add :pickup_type, :integer
    end
    create table(:trips) do
      add :trip_id, :string
      add :block_id, :string
      add :vehicle_id, :string
      add :route_id, :string
      add :last_prediction, :string
      add :destination, :string
    end
    create table(:stops) do
      add :stop_id, :string
      add :name, :string
      add :platform_name, :string
      add :platform_code, :string
      add :parent, :string
    end
    create table(:routes) do
      add :route_id, :string
      add :long_name, :string
      add :short_name, :string
      add :type, :integer
    end
    create table(:vehicles) do
      add :vehicle_id, :string
      add :trip_id, :string
      add :route_id, :string
      add :label, :string
    end
    create table(:predictions) do
      add :vehicle_id, :string
      add :prediction_id, :string
      add :trip_id, :string
      add :stop_id, :string
      add :schedule_id, :string
      add :route_id, :string
      add :status, :string
      add :schedule_relationship, :string
      add :departure_time, :utc_datetime
    end
    create table(:alerts) do
      add :alert_id, :string
      add :route_id, :string
      add :stop_id, :string
      add :trip_id, :string
      add :effect, :string
    end
    create unique_index(:alerts, [:alert_id])
    create unique_index(:schedules, [:schedule_id])
    create unique_index(:predictions, [:prediction_id])
    create unique_index(:trips, [:trip_id])
    create unique_index(:stops, [:stop_id])
    create unique_index(:routes, [:route_id])
    create unique_index(:vehicles, [:vehicle_id])
  end
end
