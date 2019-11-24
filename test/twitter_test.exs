defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter
  require Logger

  test "Test Account Creation" do
    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})

    # expect a redirect to actual data server
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})

    #expect the data to be saved to database
    assert ret == :ok
    assert reason == "Success"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId already in use"

    {ret, reason} = GenServer.call(data, {:RegisterUser, " ranbir", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId already in use"

    {ret, reason} = GenServer.call(data, {:RegisterUser, " ranbir ", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId already in use"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId cannot be empty"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "    ", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId cannot be empty"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "    ", "  "})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "UserId cannot be empty"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "  "})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "Password cannot be empty"

    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", ""})

    #ecpect the new creation to fail as the same is duplicate
    assert ret == :bad
    assert reason == "Password cannot be empty"
  end

  test "Post tweets" do

    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})

    # expect a redirect to actual data server
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})

    #expect the data to be saved to database
    assert ret == :ok
    assert reason == "Success"

    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", "My first tweet."})

    # expect a redirect to actual data server
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:PostTweet, "rabir", "roshan", "My first tweet."})
    Logger.info("#{reason}")
    #expect the data to be saved to database
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "rosan", "My first tweet."})
    Logger.info("#{reason}")
    #expect the data to be saved to database
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", "My first tweet."})

    #expect the data to be saved to database
    assert ret == :ok
    assert reason == "Success"


  end
end
