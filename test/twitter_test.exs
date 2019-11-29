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
    #assert reason == "Success"
  end

  test "Get Tweets By HashTag" do
    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "jay", "patel"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "jay", "patel"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", "My first tweet #cool."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetTweetsByHashTag, "#cool"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetTweetsByHashTag, "#cool"})
    assert ret == :ok
    assert Enum.count(reason) == 1
    [{posted_by, _a, tweet}] = reason
    assert posted_by == "ranbir"
    assert tweet == "My first tweet #cool."

    {response, data} = GenServer.call(server_pid, {:GetTweetsByHashTag, ""})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetTweetsByHashTag, ""})
    assert ret == :bad
    assert reason == "Hashtag cannot be empty"

    {response, data} = GenServer.call(server_pid, {:GetTweetsByHashTag, ""})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetTweetsByHashTag, ""})
    assert ret == :bad
    assert reason == "Hashtag cannot be empty"


    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "i am a #rockstar #cool."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "jay", "patel", "i am a #rockstar #cool."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetTweetsByHashTag, "#cool"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetTweetsByHashTag, "#cool"})
    assert ret == :ok
    assert Enum.count(reason) == 2
    [{posted_by, _a, tweet}, {posted_by_2, _b, tweet_2}] = reason
    assert posted_by == "ranbir"
    assert tweet == "My first tweet #cool."
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool."


    {response, data} = GenServer.call(server_pid, {:GetTweetsByHashTag, "#rockstar"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetTweetsByHashTag, "#rockstar"})
    assert ret == :ok
    assert Enum.count(reason) == 1
    [{posted_by_2, _b, tweet_2}] = reason
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool."
  end

  test "Get self mention" do
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

    {response, data} = GenServer.call(server_pid, {:PostTweet, "ranbir", "roshan", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "ranbir", "roshan", "My first tweet #cool."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "i am a #rockstar #cool @ranbir."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "jay", "patel", "i am a #rockstar #cool @ranbir."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetMyMention, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetMyMention, "ranbir", "roshan"})
    assert ret == :ok
    assert Enum.count(reason) == 1
    [{posted_by_2, _b, tweet_2}] = reason
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."


    {response, data} = GenServer.call(server_pid, {:PostTweet, "sid", "jain", "what a good day @ranbir."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "sid", "jain", "what a good day @ranbir."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetMyMention, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetMyMention, "ranbir", "roshan"})
    assert ret == :ok
    assert Enum.count(reason) == 2
    [{posted_by_2, _b, tweet_2}, {posted_by_3, _a, tweet_3}] = reason
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."
    assert posted_by_3 == "sid"
    assert tweet_3 == "what a good day @ranbir."

  end

  test "retweet & get tweet test" do
    {:ok, server_pid} = GenServer.start(Twitter, %{})

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "ranbir", "roshan"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:RegisterUser, "jay", "patel"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:RegisterUser, "jay", "patel"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:PostTweet, "jay", "patel", "My first tweet."})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:PostTweet, "jay", "patel", "My first tweet #cool."})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:SubscribeUser, "ranbir", "roshan", "jay"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:SubscribeUser, "ranbir", "roshan", "jay"})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert ret == :ok
    assert Enum.count(reason) == 1

    {response, data} = GenServer.call(server_pid, {:ReTweet, "ranbir", "roshan", Enum.at(reason,0)})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:ReTweet, "ranbir", "roshan", Enum.at(reason,0)})
    assert ret == :ok
    assert reason == "Success"

    {response, data} = GenServer.call(server_pid, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert response==:redirect
    {ret, reason} = GenServer.call(data, {:GetSubscribedTweet, "ranbir", "roshan"})
    assert ret == :ok
    assert Enum.count(reason) == 1


  end
end
