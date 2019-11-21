defmodule UserDataServerTest do
  use ExUnit.Case
  doctest UserDataServer

  test "CreateUser" do
    {:ok, server_pid} = GenServer.start(UserDataServer, %{})
    newUser = %UserInfo{userId: "", password: "roshan"}
    {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
    assert ret == :bad
    assert reason == "UserId cannot be empty"
    newUser = %UserInfo{userId: "ranbir", password: ""}
    {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
    assert ret == :bad
    assert reason == "Password cannot be empty"
    newUser = %UserInfo{userId: "ranbir", password: "roshan"}
    {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
    assert ret == :ok
    assert reason == "Success"
    {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
    assert ret == :bad
    assert reason == "UserId already in use"

  end
end