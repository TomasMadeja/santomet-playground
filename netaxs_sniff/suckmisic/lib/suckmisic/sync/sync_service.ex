defmodule Suckmisic.Sync.SyncService do
  alias Suckmisic.Sync.ServerRegister
  require Logger

  def register_node(server_id) do
    GenServer.call(ServerRegister, {:add, server_id})
  end

  def request_work(server_id) do
    case GenServer.call(ServerRegister, {:ready, server_id}) do
      {:ok, timeout} ->
        {:ok, :work, timeout}
      :no_work ->
        {:ok, :wait}
      :no ->
        case GenServer.call(ServerRegister, {:member?, server_id}) do
          false ->
            {:error, :unknown}
          true ->
            {:error, :assigned}
        end
    end
  end

  def done_working(server_id) do
    case GenServer.call(ServerRegister, {:done, server_id}) do
      :ok ->
        # Logger.info "Done succesfull"
        :ok
      :no ->
        # Logger.info "Done not found"
        {:error, :unknown}
    end
  end

  def request_working?(server_id) do
    {:ok, GenServer.call(ServerRegister, {:working?, server_id})}
  end

  def request_waiting?(server_id) do
    {:ok, GenServer.call(ServerRegister, {:asleep?, server_id})}
  end
end
