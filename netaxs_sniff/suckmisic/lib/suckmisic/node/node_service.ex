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

  def accept_isic(node, {uco, isic_id, description}) do
    case GenServer.call(NodeManager, {:retrieve, node}) do
      {:ok, pid} ->
        case GenServer.call(pid, {:accept, {uco, isic_id, description}}) do
          :ok ->
            :ok
          {:error, :backup} ->
            :ok
          {:error, :lost} ->
            {:error, :lost}
          {:error, :unknown} ->
            {:error, :unknown_isic}
        end
      {:error, :unknown} ->
        {:error, :unknown}
    end
  end

  def reject_isic(node, isic_id) do
    case GenServer.call(NodeManager, {:retrieve, node}) do
      {:ok, pid} ->
        case GenServer.call(pid, {:reject, isic_id}) do
          :ok ->
            :ok
          {:error, :unknown} ->
            {:error, :unknown_isic}
        end
      {:error, :unknown} ->
        {:error, :unknown}
    end
  end
end
