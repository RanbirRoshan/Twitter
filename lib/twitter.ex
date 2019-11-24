defmodule Twitter do
  use GenServer
  require Logger

  @impl true
  def init(init_arg) do

    # we assume that the user data is sharded into 26 shards for each alphabet
    database_shard_list =
      for i <- 1..26 do
        {:ok, pid} = GenServer.start(UserDataServer, %{})
        pid
      end

    data_processing_server_list =
      for i <- 1..26 do
        {:ok, pid} = GenServer.start(TwitterCoreServer, database_shard_list)
        pid
      end

    state = %{:dataShards => database_shard_list, :dataShardCount=>26, :processors=>data_processing_server_list, :processorCount=>26, :lastProcessorServer => 0}

    {:ok, state}
  end

  @moduledoc """
  Documentation for Twitter.
  """

  @impl true
  def handle_call({:RegisterUser, name, password}, _from, state) do
    nextProcessorPos = state.lastProcessorServer
    state = %{state | :lastProcessorServer => rem(state.lastProcessorServer+1, state.processorCount)}
    nextProcessorpid = Enum.at(state.processors, nextProcessorPos)
    {:reply, {:redirect, nextProcessorpid}, state}
  end

  @impl true
  def handle_call({:Login, name, password}, _from, state) do
    nextProcessorPos = state.lastProcessorServer
    state = %{state | :lastProcessorServer => rem(state.lastProcessorServer+1, state.processorCount)}
    nextProcessorpid = Enum.at(state.processors, nextProcessorPos)
    {:reply, {:redirect, nextProcessorpid}, state}
  end

  @impl true
  def handle_call({:PostTweet, name, password, tweet}, _from, state) do
    nextProcessorPos = state.lastProcessorServer
    state = %{state | :lastProcessorServer => rem(state.lastProcessorServer+1, state.processorCount)}
    nextProcessorpid = Enum.at(state.processors, nextProcessorPos)
    {:reply, {:redirect, nextProcessorpid}, state}
  end
end
