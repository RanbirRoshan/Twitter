defmodule Twitter do
  use GenServer
  require Logger

  @impl true
  def init(_init_arg) do

    # we assume that the user data is sharded into 26 shards for each alphabet
    database_shard_list =
      for _i <- 1..27 do
        {:ok, pid} = GenServer.start(UserDataServer, %{})
        pid
      end

    data_processing_server_list =
      for _i <- 1..26 do
        {:ok, pid} = GenServer.start(TwitterCoreServer, database_shard_list)
        pid
      end

    state = %{:dataShards => database_shard_list, :dataShardCount=>27, :processors=>data_processing_server_list, :processorCount=>26, :lastProcessorServer => 0}

    {:ok, state}
  end

  @moduledoc """
  Documentation for Twitter.
  """

  def redirectionData(state) do
    nextProcessorPos = state.lastProcessorServer
    state = %{state | :lastProcessorServer => rem(state.lastProcessorServer+1, state.processorCount)}
    nextProcessorpid = Enum.at(state.processors, nextProcessorPos)
    {:reply, {:redirect, nextProcessorpid}, state}
  end

  @impl true
  def handle_call({:RegisterUser, _name, _password}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:Login, _name, _password}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:PostTweet, _name, _password, _tweet}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:SubscribeUser, _name, _password, _subscribeUserName}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:DeleteUser, name, password}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:GetSubscribedTweet, name, password}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:GetTweetsByHashTag, hashTag}, _from, state) do
    redirectionData(state)
  end

  @impl true
  def handle_call({:GetMyMention, username, password}, _from, state) do
    redirectionData(state)
  end

end
