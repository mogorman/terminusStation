defmodule TerminusStation.RouteChannel do
  use Phoenix.Channel

  def join("route:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("route:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "no way dude"}}
  end
end
