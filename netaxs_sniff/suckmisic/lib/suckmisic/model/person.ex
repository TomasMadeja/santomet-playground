defmodule Suckmisic.Model.Person do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "people" do
    field :uco, :string
    field :isic, :string
    field :description, :string
  end

  def changeset(person, params) do
    person
    |> cast(params, [:uco, :isic, :description])
    |> validate_required([:uco, :isic, :description])
    |> unique_constraint(:isic)
  end

end
