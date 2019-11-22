defmodule TwitterCoreServer do
  use GenServer
  require Logger

  @impl true
  def init(init_arg) do
    state = %{:userDataMap => init_arg}
    IO.inspect(state)
    {:ok, state}
  end

  @impl true
  def handle_call({:RegisterUser, name, password}, _from, state) do
    IO.puts("request received RegisterUser #{name} #{password}")
    server_pid = Enum.at(state.userDataMap, 0)
    newUser = %UserInfo{userId: name, password: password}
    {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
    {:reply, {ret, reason}, state}
  end
end