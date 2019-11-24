defmodule TwitterCoreServer do
  use GenServer
  require Logger

  def stringTrim(data) do
    String.trim(data)
  end

  def validateUser(name, password, userObj) do
    if (name == userObj.userId && password == userObj.password) do
      true
    else
      false
    end
  end

  def convertToLower(data) do
    String.downcase(data)
  end

  def isStringNonEmpty(checkString) do
    checkString = String.trim(checkString)
    String.length(checkString) > 0
  end

  def validateNonEmptyString(data, label) do
    if isStringNonEmpty(data) do
      {:ok, "success"}
    else
      {:bad, label <> " cannot be empty"}
    end
  end

  def validateLoginData(name, password) do

    {valid, err_str} = validateNonEmptyString(name, "UserId")

    if valid == :ok do
      validateNonEmptyString(password, "Password")
    else
      {valid, err_str}
    end
  end

  def getDS(word, state) do
    pos = hd(String.to_charlist(String.at(word, 0))) - hd('a')
    {Enum.at(state.userDataMap, pos), pos}
  end

  @impl true
  def init(init_arg) do
    state = %{:userDataMap => init_arg}
    {:ok, state}
  end

  @impl true
  def handle_call({:RegisterUser, name, password}, _from, state) do

    name = stringTrim(convertToLower(name))

    {ret, reason} = validateLoginData(name, password)

    if ret == :ok do
      {server_pid, _} = getDS(name, state)# Enum.at(state.userDataMap, 0)
      newUser = %UserInfo{userId: name, password: password, tweets: []}
      {ret, reason} = GenServer.call(server_pid, {:CreateUser, newUser})
      {:reply, {ret, reason}, state}
    else
      {:reply, {ret, reason}, state}
    end
  end

  @impl true
  def handle_call({:Login, _name, _password}, _from, state) do
    {:reply, {:ok, "stub"}, state}
  end

  @impl true
  def handle_call({:PostTweet, name, password, tweet}, _from, state) do
    tweet = stringTrim(tweet)
    if isStringNonEmpty(tweet) do
      {server_pid, _} = getDS(name, state)
      {result, user} = GenServer.call(server_pid, {:GetUserById, name})
      if result == :ok do
        if (validateUser(name, password, user)) do
          {tweet_server_pid, ds_pos} = getDS(convertToLower(tweet), state)
          {:ok, tweet_id} = GenServer.call(tweet_server_pid, {:Tweet, tweet})
          updateUserInfo = %UserInfo{userId: user.userId, password: user.password, tweets: user.tweets ++ [{ds_pos, tweet_id}]}
          {:reply, GenServer.call(server_pid, {:UpdateUser, updateUserInfo}), state}
        else
          {:reply, {:bad, "Invalid user id or password"}, state}
        end
      else
        {:reply, {:bad, "Invalid user id or password"}, state}
      end
    else
      {:reply, {:bad, "Tweets cannot be empty"}, state}
    end
  end
end