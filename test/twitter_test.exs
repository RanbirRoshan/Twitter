defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  test "Test Engine Creation" do
    {:ok, server_pid} = GenServer.start(Twitter, %{})
    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    IO.puts("#{inspect response} #{inspect data}")
    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    IO.puts("#{inspect response} #{inspect data}")

    ret = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    IO.inspect(ret)
    ret2 = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    IO.inspect(ret2)
  end
end
