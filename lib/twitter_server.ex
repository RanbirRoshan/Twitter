defmodule TwitterCoreServer do
  use GenServer
  require Logger


  def flatten([]), do: []
  def flatten([h|t]), do: flatten(h) ++ flatten(t)
  def flatten(h), do: [h]

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
      {server_pid, _} = getDS(name, state)
      newUser = %UserInfo{userId: name, password: password, tweets: [], subscribedTo: []}
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
      if result == :ok && user.userDeleted == false do
        if (validateUser(name, password, user)) do
          {tweet_server_pid, ds_pos} = getDS(convertToLower(tweet), state)
          {:ok, tweet_id} = GenServer.call(tweet_server_pid, {:Tweet, {name, DateTime.utc_now(), tweet}})
          updateUserInfo = %UserInfo{userId: user.userId, password: user.password, tweets: user.tweets ++ [{ds_pos, tweet_id}], subscribedTo: user.subscribedTo}
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

  @impl true
  def handle_call({:DeleteUser, name, password}, _from, state) do
    name = convertToLower(stringTrim(name))
    if isStringNonEmpty(name) do
      {server_pid, _} = getDS(name, state)
      {result, user} = GenServer.call(server_pid, {:GetUserById, name})
      if result == :ok && user.userDeleted == false do
        if (validateUser(name, password, user)) do
          updateUserInfo = %UserInfo{userId: user.userId, password: user.password, tweets: user.tweets, subscribedTo: user.subscribedTo, userDeleted: true}
          GenServer.call(server_pid, {:UpdateUser, updateUserInfo})
          {:reply, {:ok, "Success"}, state}
        else
          {:reply, {:bad, "Invalid user id or password"}, state}
        end
      else
        {:reply, {:bad, "Invalid user id or password"}, state}
      end
    else
      {:reply, {:bad, "User Id cannot be empty"}, state}
    end
  end

  @impl true
  def handle_call({:GetSubscribedTweet, name, password}, _from, state) do
    name = convertToLower(stringTrim(name))
    if isStringNonEmpty(name) do
      {server_pid, _} = getDS(name, state)
      {result, user} = GenServer.call(server_pid, {:GetUserById, name})
      if result == :ok && user.userDeleted == false do
        if (validateUser(name, password, user)) do

          tweets =
            for sub_user <- user.subscribedTo do
              {sub_server_pid, _} = getDS(sub_user, state)
              {sub_result, sub_user_obj} = GenServer.call(sub_server_pid, {:GetUserById, sub_user})
              if sub_user_obj.userDeleted == false do
                data =
                for {tweet_server, tweet_id} <- sub_user_obj.tweets do
                  {:ok, tweet} = GenServer.call(Enum.at(state.userDataMap, tweet_server), {:GetTweet, tweet_id})
                  tweet
                end
              else
                []
              end
          end
          ret_val = flatten(tweets) |> Enum.sort_by(&(elem(&1, 1)))
          {:reply, {:ok, ret_val}, state}
        else
          {:reply, {:bad, "Invalid user id or password"}, state}
        end
      else
        {:reply, {:bad, "Invalid user id or password"}, state}
      end
    else
      {:reply, {:bad, "User Id cannot be empty"}, state}
    end
  end

  @impl true
  def handle_call({:SubscribeUser, name, password, subscribeUserName}, _from, state) do
    subscribeUserName = convertToLower(stringTrim(subscribeUserName))
    if isStringNonEmpty(subscribeUserName) do
      {server_pid, _} = getDS(name, state)
      {result, user} = GenServer.call(server_pid, {:GetUserById, name})
      {sub_server_pid, _} = getDS(subscribeUserName, state)
      {sub_result, sub_user} = GenServer.call(sub_server_pid, {:GetUserById, subscribeUserName})
      if sub_result == :ok && sub_user.userDeleted == false do
        if result == :ok do
          if (validateUser(name, password, user)) do
            if !(Enum.member?(user.subscribedTo, subscribeUserName)) do
              updateUserInfo = %UserInfo{userId: user.userId, password: user.password, tweets: user.tweets, subscribedTo: user.subscribedTo++[subscribeUserName]}
              {:reply, GenServer.call(server_pid, {:UpdateUser, updateUserInfo}), state}
            else
              {:reply, {:bad, "Already Subscribed to user"}, state}
            end
          else
            {:reply, {:bad, "Invalid user id or password"}, state}
          end
        else
          {:reply, {:bad, "Invalid user id or password"}, state}
        end
      else
        {:reply, {:bad, "User being subscribed does not have an account"}, state}
      end
    else
      {:reply, {:bad, "Subscibing user name cannot be empty"}, state}
    end
  end
end