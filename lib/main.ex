defmodule MainMod do
  require Logger

  def waitForCompletion(server_id) do
    if GenServer.call(server_id, {:isDone})==true do
      Process.sleep(500)
      waitForCompletion(server_id)
    end
  end

  def main(args \\ []) do
    [num_user, num_tweet] = args
    {num_user, _} = Integer.parse(num_user)
    {num_tweet, _} = Integer.parse(num_tweet)
    {:ok, server_id} = GenServer.start(NewMain, {num_user, num_tweet})
    GenServer.cast(server_id, {:start})
    waitForCompletion(server_id)
    Process.sleep(10000)
  end
end

defmodule NewMain do
  use GenServer
  require Logger
  # Dosassignment2]
  @alphabets "abcdefghijklmnopqrstuvwxyz"
  @follow_count_percent 0.30
  #@tweet_count 500
  @hash_tag_list_size 2 #100
  @max_hash_count_per_msg 10
  #@number_of_users  25 #100
  @max_wait_time_milli_sec 200

  @impl true
  def init(init_arg) do
    {num_user, num_tweet} = init_arg
    state = %{:num_start_end_pending => num_user, :numUser=>num_user, :numMsg=>num_tweet}
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

  def generateHashTagList(count, list) do
    if count>0 do
      hash_len = :rand.uniform(4)
      hash = "#" <> getRandomString(5+hash_len, "")
      if (Enum.find_index(list,  fn(hash_data) -> hash_data == hash end)) == nil do
        generateHashTagList(count-1, list ++ [hash])
      else
        generateHashTagList(count, list)
      end
    else
      list
    end
  end

  def createRandomUserIdPassowrd(count, list) do
    if (count == 0) do
      list
    else
      uniquelen = 4 + :rand.uniform(10)
      username_new = getRandomString(uniquelen, "") #<> "@" <> getRandomString(4, "") <> ".com"
      passwordLen = 8 + :rand.uniform(4)
      password = getRandomString(passwordLen, "")
      if (Enum.find_index(list,  fn({username, _password}) -> username == username_new end)) == nil do
        createRandomUserIdPassowrd(count-1, list ++ [{username_new, password}])
      else
        IO.puts("found")
        createRandomUserIdPassowrd(count, list)
      end
    end
  end

  def createClientAccount(count, server_id, list_user, client_list, hash_tag_list, numMsg) do
    if (count > 0) do
      follow_count = Enum.count(list_user) * @follow_count_percent
      data = {count-1, list_user, follow_count, numMsg, hash_tag_list, server_id, self(), @max_hash_count_per_msg}
      {:ok, client_pid} = GenServer.start(Client, data)
      GenServer.call(client_pid, {:createAccount})
      createClientAccount(count-1, server_id, list_user, client_list ++ [client_pid], hash_tag_list, numMsg)
    else
      client_list
    end
  end

  def startClient(client_list, pos) do
    if pos < Enum.count(client_list) do
      GenServer.cast(Enum.at(client_list,pos), {:start, @max_wait_time_milli_sec})
      startClient(client_list, pos+1)
    end
  end

  @impt true
  def handle_call({:InformStartCompletion}, _from, state) do
    state = %{state| :num_start_end_pending => state.num_start_end_pending -1}
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:isDone}, _from, state) do
    if (state.num_start_end_pending > 0) do
      {:reply, false, state}
    else
      {:reply, false, state}
    end
  end

  @impl true
  def handle_cast({:start}, state) do
    userid_pwd_list = createRandomUserIdPassowrd(state.numUser, [])
    {:ok, server_id} = GenServer.start(Twitter, %{})
    hash_list   = generateHashTagList(@hash_tag_list_size, [])
    client_list = createClientAccount(state.numUser, server_id, userid_pwd_list, [], hash_list, state.numMsg)
    startClient(client_list, 0)
    IO.inspect(client_list)
    {:noreply, state}
  end



end