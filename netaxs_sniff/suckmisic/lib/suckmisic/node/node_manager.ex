defmodule Suckmisic.Node.NodeManager do
  use GenServer

  alias Suckmisic.Node.Node
  alias Suckmisic.Node.NodeSupervisor

  @archive_folder "storage/archive"
  @batch_folder "storage/batch"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    File.mkdir_p!(@archive_folder)
    File.mkdir_p!(@batch_folder)
    {:ok, %{}}
  end

  def handle_call(
    {:retrieve, node},
    _from,
    nodes
  ) do
    case Map.fetch(nodes, node) do
      {:ok, pid} ->
        {:reply, {:ok, pid}, nodes}
      :error ->
        {:reply, {:error, :unknown}, nodes}
    end
  end

  def handle_call(
    {:spawn, node},
    _from,
    nodes
  ) do
    case Map.has_key?(nodes, node) do
      false ->
        case spawn_node(node) do
          {:ok, pid, isics} ->
            {:reply, {:ok, isics}, Map.put_new(nodes, node, pid)}
          {:error, code} ->
            {:reply, {:error, code}, nodes}
        end
      true ->
        {:reply, {:error, :exists}, nodes}
    end
  end

  def handle_call(
    {:terminate, node},
    _from,
    nodes
  ) do
    case Map.has_key?(nodes, node) do
      false ->
        case terminate_node(Map.get(nodes, node)) do
          :ok ->
            {:reply, :ok, Map.delete(nodes, node)}
          {:error, :not_found, _cfg} ->
            {:reply, :ok, nodes}
          {:error, :posix, _cfg} ->
            {:reply, {:error, :file_system}, nodes}
        end
      true ->
        {:reply, {:error, :not_exists}, nodes}
    end
  end

  defp spawn_node(node) do
    r = %{node: node}
      |> retrieve_new_batch
      |> archive_batch
      |> load_batch
      |> spawn_process
    case r do
      {:ok, %{pid: pid, isics: isics}} ->
        {:ok, pid, isics}
      {:error, :empty, _cfg} ->
        {:error, :empty}
      {:error, {:posix, _code}, _cfg} ->
        {:error, :posix}
      {:error, :ignore, cfg} ->
        return_batch({:ok, cfg})
        {:error, :spawn_error}
      {:error, :spawn, cfg} ->
        return_batch({:ok, cfg})
        {:error, :spawn_error}
    end
  end

  defp retrieve_new_batch({:ok, cfg = %{node: _node}}) do
    case File.ls!(@batch_folder) do
      files when files != [] ->
        name = Enum.at(files, 0)
        {
          :ok,
          Map.merge(
            cfg,
            %{
              batch: Path.join(@batch_folder, name),
              batch_id: name
            }
          )
        }
      _ ->
        {:error, :empty, cfg}
    end
  end

  defp retrieve_new_batch(r = {:error, _reason, _cfg}), do: r

  defp archive_batch({:ok, cfg = %{batch: batch}}) do
    archive_path = Path.join(
      @archive_folder,
      Path.basename(batch)
    )
    case File.cp(batch, archive_path) do
      :ok ->
        {:ok, Map.put(cfg, :batch, archive_path)}
      {:error, code} ->
        {:error, {:posix, code}, cfg}
    end
  end

  defp archive_batch(r = {:error, _reason, _cfg}), do: r

  defp load_batch({:ok, cfg = %{batch: batch}}) do
    isics =
      File.stream!(batch)
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list()
    {:ok, Map.put(cfg, :isics, isics)}
  end

  defp load_batch(r = {:error, _reason, _cfg}), do: r

  defp spawn_process(
    {
      :ok,
      cfg = %{
        node: node,
        batch_id: batch_id,
        isics: isics
      }
    }
  ) do
    case DynamicSupervisor.start_child(
      NodeSupervisor,
      {Node, {node, batch_id, isics}}
    ) do
      {:ok, pid} ->
        {:ok, Map.put(cfg, :pid, pid)}
      {:ok, pid, _} ->
        {:ok, Map.put(cfg, :pid, pid)}
      :ignore ->
        {:error, :ignore, cfg}
      {:error, _} ->
        {:error, :spawn, cfg}
    end
  end

  defp spawn_process(r = {:error, _reason, _cfg}), do: r

  defp return_batch({:ok, cfg = %{batch: batch}}) do
    batch_path = Path.join(
      @batch_folder,
      Path.basename(batch)
    )
    case File.cp(batch, batch_path) do
      :ok ->
        {:ok, Map.put(cfg, :batch, batch_path)}
      {:error, code} ->
        {:error, {:posix, code}, cfg}
    end
  end

  defp return_batch(r = {:error, _reason, _cfg}), do: r

  defp terminate_node(pid) do
    {node_id, batch_id, _isics} = GenServer.call(pid, :dump)
    r = %{
      pid: pid,
      batch: Path.join(@archive_folder, batch_id),
      node: node_id
    }
     |> return_batch
     |> kill_node
    case r do
      {:ok, _cfg} ->
        :ok
      {:error, :not_found, _cfg} ->
        {:error, :not_found}
      {:error, {:posix, _code}, _cfg} ->
        {:error, :posix}
    end
  end

  defp kill_node(
    {:ok, cfg = %{pid: pid}}
  ) do
    case DynamicSupervisor.terminate(NodeSupervisor, pid) do
      :ok ->
        {:ok, cfg}
      {:error, :not_found} ->
        {:error, :not_found, cfg}
    end
  end

  defp kill_node(r = {:error, _reason, _cfg}), do: r

end
