defmodule SuckmisicWeb.NodeController do
  use SuckmisicWeb, :controller
  alias Suckmisic.Node.NodeService


  def spawn(conn, %{"node" => node_id}) do
    case NodeService.spawn_node(node_id) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id
          }
        )
      {:error, :exists} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "exists",
            "error" => "existing id"
          }
        )
      {:error, :no_work} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "no_work",
            "error" => "no work to be done"
          }
        )
      {:error, :internal} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "internal",
            "error" => "internal error occured"
          }
        )
    end
  end

  def terminate(conn, %{"node" => node_id}) do
    case NodeService.terminate_node(node_id) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id
          }
        )
      {:error, :not_exists} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "not_exists",
            "error" => "id doesn't exist"
          }
        )
      {:error, :internal} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "internal",
            "error" => "internal error occured"
          }
        )
    end
  end

  def exists(conn, %{"node" => node_id}) do
    r = NodeService.exists_node?(node_id)
    conn
    |> put_status(200)
    |> json(
      %{
        "status" => "ok",
        "node" => node_id,
        "response" => r
      }
    )
  end
end
