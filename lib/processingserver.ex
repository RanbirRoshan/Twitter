defmodule Controller do
  use GenServer
  require Logger

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start(initial_state) do
    #Logger.info("Starting server with an inital state: #{inspect initial_state}")
    GenServer.start(__MODULE__, initial_state, [])
  end

end