defmodule SuckmisicWeb.SyncController do
  use SuckmisicWeb, :controller
  alias Suckmisic.Sync.SyncService

  def register(conn, %{"node" => node_id}) do
    case SyncService.register_node(node_id) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id
          }
        )
      :error ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "exists",
            "error" => "existing id"
          }
        )
    end
  end

  def request(conn, %{"node" => node_id}) do
    case SyncService.request_work(node_id) do
      {:ok, :work, timeout} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "work",
            "time" => timeout
          }
        )
      {:ok, :wait} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "wait"
          }
        )
      {:error, :unknown} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "unknown",
            "error" => "unknown id"
          }
        )
      {:error, :assigned} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "working",
            "error" => "already working"
          }
        )
    end
  end

  def done(conn, %{"node" => node_id}) do
    case SyncService.done_working(node_id) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "ok",
          }
        )
      {:error, :unknown} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "skip",
            "error" => "not found"
          }
        )
    end
  end

  def is_working(conn, %{"node" => node_id}) do
    {:ok, t} = SyncService.request_working?(node_id)
    conn
    |> put_status(200)
    |> json(
      %{
        "node" => node_id,
        "status" => "evaluated",
        "answer" => t
      }
    )
  end

  def is_waiting(conn, %{"node" => node_id}) do
    {:ok, t} = SyncService.request_waiting?(node_id)
    conn
    |> put_status(200)
    |> json(
      %{
        "node" => node_id,
        "status" => "evaluated",
        "answer" => t
      }
    )
  end
end
