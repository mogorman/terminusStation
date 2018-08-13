defmodule TerminusStation.UpdateSchedule do
  use GenStage

  def start_link(opts) do
    start_link_opts = Keyword.take(opts, [:name])
    opts = Keyword.drop(opts, [:name])
    GenStage.start_link(__MODULE__, opts, start_link_opts)
  end

  def init(opts) do
    {:consumer, %{"board" => ""}, opts}
  end

  def handle_events(events, {from, _ref}, state) do
    {:registered_name, fromAdress} = List.keyfind(Process.info(from), :registered_name, 0)
    {:noreply, [], eat_events(state, fromAdress, events)}
  end

  # process all events updating schedule, then check to see if we need to update the board.
  def eat_events(state, :event_cron_producer, _events) do
    board = TerminusStation.Stations.update_board(Map.get(state, "board"))
    Map.put(state, "board", board)
  end

  def eat_events(state, _from, []) do
    state
  end

  def eat_events(state, from, [head | tail]) do
    process_event(from, Jason.decode!(head.data), head.event)
    eat_events(state, from, tail)
  end

  def process_event(_from, [], _event) do
    nil
  end

  def process_event(from, data = [head | tail], "remove") when is_list(data) do
    process_event(from, head, "remove")
    process_event(from, tail, "remove")
  end

  def process_event(_from, data, "remove") do
    type = Map.get(data, "type")
    id = Map.get(data, "id")
    TerminusStation.Stations.remove(data, type, id)
  end

  def process_event(:event_schedule_producer, data, "reset") do
    TerminusStation.Stations.drop_most()
    process_event(:event_schedule_producer, data, "update")
  end

  def process_event(:event_alert_producer, data, "reset") do
    TerminusStation.Stations.drop_alerts()
    process_event(:event_alert_producer, data, "update")
  end

  def process_event(:event_prediction_producer, data, "reset") do
    TerminusStation.Stations.drop_predictions()
    process_event(:event_prediction_producer, data, "update")
  end

  def process_event(from, data = [head | tail], event) when is_list(data) do
    process_event(from, head, event)
    process_event(from, tail, event)
  end

  def process_event(from, data, _event) do
    type = Map.get(data, "type")
    id = Map.get(data, "id")
    TerminusStation.Stations.update(data, from, type, id)
  end
end
