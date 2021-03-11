defmodule SuckmisicWeb.CrackController do
  use SuckmisicWeb, :controller

  alias Suckmisic.Crack.CrackService

  def submit(
    conn,
    %{
      "node" => _node,
      "success" => accept,
      "fail" => _reject
    }
  ) do
    results = Enum.map(
      accept,
      fn %{"user_id" => isic, "uco" => uco, "name" => name} -> {uco, isic, name} end
    )
    case CrackService.publish_success_all(results) do
      true ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "ok"
          }
        )
      false ->
        conn
        |> put_status(200)
        |> json(
          %{
            "status" => "error",
            "message" => "error storing"
          }
        )
    end
  end

end
