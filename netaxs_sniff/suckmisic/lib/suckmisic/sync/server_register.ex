defmodule Suckmisic.Sync.ServerRegister do
  use GenServer
  alias Suckmisic.Sync.SyncConfig

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, {MapSet.new(), MapSet.new()}}
  end

  def handle_call({:add, server_id}, _from, {working, asleep}) do
    case member?(server_id, working, asleep) do
      false ->
        {:reply, :ok, {working, MapSet.put(asleep, server_id)}}
      true ->
        {:reply, :error, {working, asleep}}
    end
  end

  def handle_call({:ready, server_id}, _from, {working, asleep}) do
    count = GenServer.call(SyncConfig, :count)
    case MapSet.size(working) do
      x when x < count ->
        case MapSet.member?(asleep, server_id) and not MapSet.member?(working, server_id) do
          true ->
            timeout = GenServer.call(SyncConfig, :timeout)
            {:reply, {:ok, timeout}, {MapSet.put(working, server_id), MapSet.delete(asleep, server_id)}}
          false ->
            {:reply, :no, {working, asleep}}
        end
      _ ->
        {:reply, :no_work, {working, MapSet.put(asleep, server_id)}}
    end
  end

  def handle_call({:done, server_id}, _from, {working, asleep}) do
    case MapSet.member?(working, server_id) do
      true ->
        {:reply, :ok, {MapSet.delete(working, server_id), MapSet.put(asleep, server_id)}}
      false ->
        {:reply, :no, {working, asleep}}
    end
  end

  def handle_call({:member?, server_id}, _from, {working, asleep}) do
    {:reply, member?(server_id, working, asleep), {working, asleep}}
  end

  def handle_call({:asleep?, server_id}, _from, {working, asleep}) do
    {:reply, MapSet.member?(asleep, server_id), {working, asleep}}
  end

  def handle_call({:working?, server_id}, _from, {working, asleep}) do
    {:reply, MapSet.member?(working, server_id), {working, asleep}}
  end

  defp member?(server_id, working, asleep) do
    MapSet.member?(asleep, server_id) or MapSet.member?(working, server_id)
  end
end
