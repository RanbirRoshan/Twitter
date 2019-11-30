defmodule Client do
  use GenServer
  require Logger

  @alphabets "abcdefghijklmnopqrstuvwxyz"

  @impl true
  def init(init_arg) do
    {self_id, others, follow_count, tweet_count, hash_tag_list, server_id, owner, hash_count_per_msg} = init_arg
    tweet_count = div(tweet_count,self_id+1)
    {name, password} = Enum.at(others, self_id)
    others = List.delete(others, {name, password})
    state = %{:server_id => server_id, :userDataMap => others, :myId => self_id, :fill_list => others, :follow_count => follow_count,
      :tweet_count => tweet_count, :hash_tag_list => hash_tag_list, :owner=>owner,
      :hashCount=> hash_count_per_msg, :name=>name, :password=>password, :informedCompletion=>false}
    {:ok, state}
  end

  def getRandomString(len, ans) do
    if len > 0 do
      random = :rand.uniform(26) - 1
      ans = ans <> String.at(@alphabets, random)
      getRandomString(len-1, ans)
    else
      ans
    end
  end

  def getRandomTweet(len, line, tags, people) do
    if len > 0 do
      chance = :rand.uniform(100)
      line =
      if chance > 90 do
        tag_pos = :rand.uniform(Enum.count(tags)) - 1
        line <> " " <> Enum.at(tags, tag_pos)
      else
        line
      end
      chance = :rand.uniform(100)
      line =
        if chance > 90 do
          tag_pos = :rand.uniform(Enum.count(people)) - 1
          {name, pwd} = Enum.at(people, tag_pos)
          line <> " @" <> name
        else
          line
        end

      word = getRandomString(1+:rand.uniform(10), "")
      getRandomTweet(len-1, line <> " " <> word, tags, people)
    else
      line
    end
  end

  def performRetweet(state) do
    {ret, data} = sendInfoToServer(state.server_id, {:GetSubscribedTweet, state.name, state.password}, false)
    if (Enum.count(data) == 0) do
      false
    else
      data = {:ReTweet, state.name, state.password, Enum.at(data,:rand.uniform(Enum.count(data))-1)}
      {:ok, data} = sendInfoToServer(state.server_id, data, false)
      #Logger.info("Retweet action successful")
      true
    end
  end

  def getAllTweets(state) do
    {ret, data} = sendInfoToServer(state.server_id, {:GetSubscribedTweet, state.name, state.password}, false)
    #Logger.info("Total number of tweets on wall (ID: #{state.myId}): #{inspect Enum.count(data)}")
  end

  def getAllTags(state) do
    for tag <- state.hash_tag_list do
      {ret, data} = sendInfoToServer(state.server_id, {:GetTweetsByHashTag, tag}, false)
      #Logger.info("No of tweets by hashtag (ID: #{state.myId}, Tag: #{tag}): #{inspect Enum.count(data)}")
    end
  end

  def subscribeRandomUser(state) do
    {name, _} = Enum.random(state.userDataMap)
    sendInfoToServer(state.server_id, {:SubscribeUser, state.name, state.password, name}, false)
  end

  def getAllMentions(state) do
    {ret, data} = sendInfoToServer(state.server_id, {:GetMyMention, state.name, state.password}, false)
    #Logger.info("Number of tweets mentions (ID: #{state.myId}): #{inspect Enum.count(data)}")
  end

  def followUser(state, count) do
    if (count > 0) do
      {name, _} = Enum.at(state.userDataMap, count-1)
      sendInfoToServer(state.server_id, {:SubscribeUser, state.name, state.password, name}, false)
      followUser(state, count-1)
    end
  end

  def startWorking(state, max_wait_time_milli_sec) do

    chance = :rand.uniform(100)
    if chance < 40 do
      logouttime = :rand.uniform(100)
      sendInfoToServer(state.server_id, {:Logout, state.name, state.password}, false)
      #Logger.info("User Logs Out (ID: #{state.myId})")
      Process.sleep(logouttime)
      ret = sendInfoToServer(state.server_id, {:Login, state.name, state.password}, false)
      #Logger.info("User Logs Back In (ID: #{state.myId})")
    end
    state=
    if (state.tweet_count > 0) do
      chance = :rand.uniform(100)
      if chance < 40 do

        chance = :rand.uniform(100)
        change =
        if chance > 20 do
          words = 10 + :rand.uniform(20)

          tweet = getRandomTweet(words, "", state.hash_tag_list, state.userDataMap)
          sendInfoToServer(state.server_id, {:PostTweet, state.name, state.password, tweet}, false)
          1
        else
          if (performRetweet(state)) do
            1
          else
            0
          end
        end
        state = %{state | :tweet_count => state.tweet_count - change}
        Process.sleep(:rand.uniform(max_wait_time_milli_sec))
        state
      else
        chance = :rand.uniform(100)

        if chance > 55 do
          getAllTweets(state)
        end
        if  chance > 30 && chance <= 55 do
            getAllTags(state)
        end
        if  chance <= 30 do
            getAllMentions(state)
        end
#        if  chance <= 15 do
#          subscribeRandomUser(state)
#        end
        state
      end
    else
      getAllTweets(state)
      if state.informedCompletion == false do
        #IO.puts("Completed : #{state.myId}")
        GenServer.call(state.owner, {:InformStartCompletion})
        %{state | :informedCompletion => true}
      else
        state
      end
    end
    Process.sleep(:rand.uniform(max_wait_time_milli_sec))
    startWorking(state, max_wait_time_milli_sec)
  end

  def sendInfoToServer(server_id, data, print) do
    {ret, ret_data} = GenServer.call(server_id, data, 9999999)
    if print == true do
      #Logger.info("#{inspect {ret, ret_data, data}}")
    end
    if (ret == :redirect) do
      sendInfoToServer(ret_data, data, print)
    else
      {ret, ret_data}
    end
  end

  @impl true
  def handle_cast({:Notification, data}, state) do
    #Logger.info("Notification Received(User Id: #{state.myId}): " <> data)
    {:noreply, state}
  end

  @impl true
  def handle_call({:createAccount}, _from, state) do
    ret = sendInfoToServer(state.server_id, {:RegisterUser, state.name, state.password}, false)
    ret = sendInfoToServer(state.server_id, {:Login, state.name, state.password}, false)
    {:reply, ret, state}
  end

  @impl true
  def handle_cast({:start, max_wait_time_milli_sec}, state) do
    pid_btc = spawn fn ->
      followUser(state, state.myId)
      startWorking(state, max_wait_time_milli_sec)
    end
    {:noreply, state}
  end
end