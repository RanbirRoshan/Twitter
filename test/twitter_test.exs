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

  test "Delete User" do

    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:DeleteUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:DeleteUser, "ranbir", "roshan"})
    assert ret == :ok
    assert reason == "Success"
    {response, data} = GenServer.call(server_pid, {:DeleteUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:DeleteUser, "ranbir", "roshan"})
    assert ret == :bad
    assert reason == "Invalid user id or password"

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

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:PostTweet, "rabir", "roshan", "My first tweet."})
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "rosan", "My first tweet."})
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", " "})
    assert ret == :bad
    assert reason == "Tweets cannot be empty"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", ""})
    assert ret == :bad
    assert reason == "Tweets cannot be empty"
  end

  test "Subscribe User" do

    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "sid", "jain"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "sid", "jain"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "jay", "patel"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "jay", "patel"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "rabir", "roshan", "sid"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "rabir", "roshan", "sid"})
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "rosan", "sid"})
    assert ret == :bad
    assert reason == "Invalid user id or password"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "jay"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "jay"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", " "})
    assert ret == :bad
    assert reason == "Subscibing user name cannot be empty"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert response==:redirect

    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", ""})
    assert ret == :bad
    assert reason == "Subscibing user name cannot be empty"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "sid"})
    assert ret == :bad
    assert reason == "Already Subscribed to user"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "siddu"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "siddu"})
    assert ret == :bad
    assert reason == "User being subscribed does not have an account"

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "Mukul", "mehra"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "Mukul", "mehra"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:DeleteUser, "Mukul", "mehra"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:DeleteUser, "Mukul", "mehra"})
    assert ret == :ok
    assert reason == "Success"


    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "Mukul"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "Mukul"})
    assert ret == :bad
    assert reason == "User being subscribed does not have an account"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "sid", "jain", "sid's first tweet."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "jay", "patel", "Jay's first tweet."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "sid", "jain", "sid's second tweet."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert ret == :ok
    IO.inspect(reason)
    #assert reason == "Success"
  end
end
