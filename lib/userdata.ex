defmodule UserInfo do
  defstruct userId: "", password: "", tweets: []
end

defmodule UserDataServer do
  use GenServer
  require Logger

  def hello do
    :world
  end

  @impl true
  def init(init_arg) do
    user_table = :ets.new(:user_lookup, [:set, :protected])
    tweet_table = :ets.new(:tweet_lookup, [:set, :protected])
    state = %{:userTable => user_table, :tweetTable => tweet_table, :tweetCount => 0}
    {:ok, state}
  end

  @impl true
  def handle_call({:CreateUser, userData}, _from, state) do

    is_new = :ets.insert_new(state.userTable, {userData.userId, userData})

    if is_new do
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "UserId already in use"}, state}
    end
  end

  @impl true
  def handle_call({:DeleteUser, userId}, _from, state) do
    #IO.inspect(userId)
    data = :ets.lookup(state.userTable, userId)
    if Enum.count(data) > 0 do
      :ets.delete(state.userTable, userId)
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end

  @impl true
  def handle_call({:GetUserById, userId}, _from, state) do
    data = :ets.lookup(state.userTable, userId)
    if Enum.count(data) > 0 do
      {_id, user} = Enum.at(data, 0)
      {:reply, {:ok, user}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end

  @impl true
  def handle_call({:Tweet, tweet}, _from, state) do
    tweet_id = state.tweetCount
    state = %{state | :tweetCount=>tweet_id+1}
    :ets.insert_new(state.tweetTable, {tweet_id,tweet})
    {:reply, {:ok, tweet_id}, state}
  end

  @impl true
  def handle_call({:UpdateUser, user}, _from, state) do
    data = :ets.lookup(state.userTable, user.userId)
    if Enum.count(data) > 0 do
      :ets.insert(state.userTable, {user.userId, user})
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end
end