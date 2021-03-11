defmodule Suckmisic.Node.Node do
  use GenServer

  alias Suckmisic.Model.Person
  alias Suckmisic.Repo

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init({node_id, batch_id, isics}) do
    {:ok, {node_id, batch_id, isics}}
  end

  def handle_call({:accept, {uco, isic_id, description}}, _from, {node_id, batch_id, isics}) do
    case MapSet.member?(isics, isic_id) do
        true ->
          case publish_success(uco, isic_id, description) do
            :ok ->
              isics = MapSet.delete(isics, isic_id)
              {:reply, :ok, {node_id, batch_id, isics}}
            {:error, :backup} ->
              isics = MapSet.delete(isics, isic_id)
              {:reply, {:error, :backup}, {node_id, batch_id, isics}}
            {:error, :lost} ->
              {:reply, {:error, :lost}, {node_id, batch_id, isics}}
          end
        false ->
          {:reply, {:error, :unknown}, {node_id, batch_id, isics}}
    end
  end

  def handle_call({:reject, isic_id}, _from, {node_id, batch_id, isics}) do
    case MapSet.member?(isics, isic_id) do
      true ->
        isics = MapSet.delete(isics, isic_id)
        {:reply, {:ok, isic_id}, {node_id, batch_id, isics}}
      false ->
        {:reply, {:error, :unknown}, {node_id, batch_id, isics}}
    end
  end

  def handle_call(:empty?, _from, {node_id, batch_id, isics}) do
    case MapSet.size(isics) do
      0 ->
        {:reply, true, {node_id, batch_id, isics}}
      _ ->
        {:reply, false, {node_id, batch_id, isics}}
    end
  end

  def handle_call(:dump, _from, state={_node_id, _batch_id, _isics}) do
      {:reply, state, state}
  end

  defp publish_success(uco, isic, description) do
    person = Person.changeset(
      %Person{},
      %{
        uco: uco,
        isic: isic,
        description: description
      }
    )
    case Repo.insert(person) do
      {:ok, } ->
        :ok
      {:error, _changeset} ->
        case Jason.encode(
          %{
            "uco" => uco,
            "isic" => isic,
            "description" => description
          }
        ) do
          {:ok, msg} ->
            record_erronous(msg)
            {:error, :backup}
          {:error, _error_msg} ->
            {:error, :lost}
        end
      end
  end

  defp record_erronous(_entry) do
    :ok
  end
end
