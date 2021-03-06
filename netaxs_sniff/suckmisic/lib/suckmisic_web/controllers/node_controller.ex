defmodule SuckmisicWeb.NodeController do
  use SuckmisicWeb, :controller
  alias Suckmisic.Node.NodeService


  def spawn(conn, %{"node" => node_id}) do
    case NodeService.spawn_node(node_id) do
      {:ok, isics} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id,
            "isics" => isics
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

  def accept(
    conn,
    %{
      "node" => node_id,
      "uco" => uco,
      "isic" => isic,
      "description" => description
    }
  ) do
    case NodeService.accept_isic(node_id, {uco, isic, description}) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id
          }
        )
      {:error, :lost} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "lost",
            "error" => "isic result was lost"
          }
        )
      {:error, :unknown_isic} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "unknown_isic",
            "error" => "unknown isic"
          }
        )
      {:error, :unknown} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "unknown_node",
            "error" => "unknown node"
          }
        )
    end
  end

  def reject(
    conn,
    %{
      "node" => node_id,
      "isic" => isic
    }
  ) do
    case NodeService.accept_isic(node_id, isic) do
      :ok ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok",
            "node" => node_id
          }
        )
      {:error, :unknown_isic} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "unknown_isic",
            "error" => "unknown isic"
          }
        )
      {:error, :unknown} ->
        conn
        |> put_status(200)
        |> json(
          %{
            "node" => node_id,
            "status" => "unknown_node",
            "error" => "unknown node"
          }
        )
    end
  end
end
