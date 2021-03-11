defmodule Suckmisic.Crack.CrackService do
  alias Suckmisic.Model.Person
  alias Suckmisic.Repo

  def publish_success(uco, isic, description) do
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
            :error
          {:error, _error_msg} ->
            :error
        end
    end
  end

  def publish_success_all(results) do
    results
    |> Enum.map(fn {uco, isic, description} -> publish_success(uco, isic, description) end)
    |> Enum.all?(fn x -> x == :ok end)
  end

  defp record_erronous(_entry) do

  end



end
