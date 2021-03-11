defmodule Suckmisic.Node.NodeService do
  alias Suckmisic.Node.NodeManager

  def spawn_node(node) do
    case GenServer.call(NodeManager, {:spawn, node}) do
      {:ok, isics} ->
        {:ok, isics}
      {:error, :exists} ->
        {:error, :exists}
      {:error, :empty} ->
        {:error, :no_work}
      {:error, _} ->
        {:error, :internal}
    end
  end

  def exists_node?(node) do
    case GenServer.call(NodeManager, {:retrieve, node}) do
      {:ok, _pid} ->
        true
      {:error, :unknown} ->
        false
    end
  end

  def terminate_node(node) do
    case GenServer.call(NodeManager, {:terminate, node}) do
      :ok ->
        :ok
      {:error, :file_system} ->
        {:error, :internal}
      {:error, :not_exists} ->
        {:error, :not_exists}
    end
  end
end
