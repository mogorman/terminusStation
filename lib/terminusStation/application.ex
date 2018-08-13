defmodule TerminusStation.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # @todo learn to do config files correctly.
    api_key = "&api_key=GETYOUROWNKEY"

    schedule_url =
      "https://api-v3.mbta.com/schedules?include=stop,route,prediction,trip&sort=departure_time&filter[stop]=place-north,place-sstat" <>
        api_key

    prediction_url =
      "https://api-v3.mbta.com/predictions/?include=schedule,stop,route,vehicle,trip&filter[stop]=place-sstat,place-north" <>
        api_key

    alert_url =
      "https://api-v3.mbta.com/alerts?include=stops,routes,trips&filter[activity]=BOARD,EXIT,RIDE&filter[route_type]=2&filter[stop]=place-sstat,place-north" <>
        api_key

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(TerminusStation.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TerminusStationWeb.Endpoint, []),
      supervisor(TerminusStation.CronUpdateSchedule, [nil]),
      Supervisor.child_spec(
        {ServerSentEventStage, name: :event_schedule_producer, url: schedule_url},
        id: :schedules
      ),
      Supervisor.child_spec(
        {ServerSentEventStage, name: :event_prediction_producer, url: prediction_url},
        id: :predictions
      ),
      Supervisor.child_spec(
        {ServerSentEventStage, name: :event_alert_producer, url: alert_url},
        id: :alerts
      ),
      Supervisor.child_spec(
        {TerminusStation.UpdateSchedule,
         subscribe_to: [
           :event_schedule_producer,
           :event_alert_producer,
           :event_prediction_producer,
           :event_cron_producer
         ]},
        []
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      strategy: :one_for_one,
      name: TerminusStation.Supervisor,
      restart: :permanent,
      max_restarts: 10_000
    ]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TerminusStationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
