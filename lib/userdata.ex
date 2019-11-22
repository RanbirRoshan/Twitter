defmodule UserInfo do
  defstruct userId: "", password: ""
end

defmodule UserDataServer do
  use GenServer
  require Logger

  def hello do
    :world
  end

  def validateNonEmptyString(data, label) do
    if String.length(data) == 0 do
      {false, label <> " cannot be empty"}
    else
      {true, "success"}
    end
  end

  def validateUser(data) do
    {valid, err_str} = validateNonEmptyString(data.userId, "UserId")

    if valid do
      validateNonEmptyString(data.password, "Password")
    else
      {valid, err_str}
    end
  end

  @impl true
  def init(init_arg) do
    state = %{:userDataMap => %{}}
    {:ok, state}
  end

  def start(args) do
    state = %{:userDataMap => %{}}
    GenServer.start(__MODULE__, state, [])
  end

  @impl true
  def handle_call({:CreateUser, userData}, _from, state) do
    {isValid, errorString}= validateUser(userData)
    {ret, errorString, state} =
    if (isValid) do
      # check if the user id is unique
      {status, reason} =
      if Map.has_key?(state.userDataMap, String.to_atom(userData.userId)) do
        #not unique
        {:bad, "UserId already in use"}
      else
        {:ok, "Success"}
      end
      # insert the user as registered user
      if status == :bad do
        {status, reason, state}
      else
        userMap = Map.put(state.userDataMap, String.to_atom(userData.userId), userData)
        state = %{state | :userDataMap => userMap}
        {:ok, reason, state}
      end
    else
      {:bad, errorString, state}
    end
    {:reply, {ret, errorString}, state}
  end

  @impl true
  def handle_call({:DeleteUser, userId}, _from, state) do
    {ret, errorString, state} =
      if Map.has_key?(state.userDataMap, String.to_atom(userId)) do
        #not unique
        userMap = Map.delete(state.userDataMap, String.to_atom(userId))
        #session delete
        state = %{state | :userDataMap => userMap}
        {:ok, "Success", state}
      else
        {:bad, "Invalid User ID", state}
      end
    {:reply, {ret, errorString}, state}
  end

end