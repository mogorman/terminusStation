defmodule TerminusStation.CronUpdateSchedule do
  use GenStage
  require Logger

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: :event_cron_producer)
  end

  def init(state) do
    {:producer, state}
  end

  def handle_cast(:check_for_messages, 0) do
    {:noreply, [], 0}
  end

  def handle_cast(:check_messages, _state) do
    # Fire an event once every 60 seconds to update our terminal board even if no other events are fired
    Process.sleep(10000)
    GenStage.cast(:event_cron_producer, :check_messages)
    {:noreply, [%{data: "{\"event\":\"tick\"}", event: "message"}], :ok}
  end

  def handle_demand(_demand, _state) do
    GenStage.cast(:event_cron_producer, :check_messages)
    {:noreply, [], :ok}
  end
end
