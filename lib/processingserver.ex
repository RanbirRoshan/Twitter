defmodule Controller do
  use GenServer
  require Logger

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start(initial_state) do
    GenServer.start(__MODULE__, initial_state, [])
  end

end