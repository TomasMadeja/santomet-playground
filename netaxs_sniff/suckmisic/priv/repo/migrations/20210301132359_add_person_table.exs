defmodule Suckmisic.Repo.Migrations.AddPersonTable do
  use Ecto.Migration

  def change do
    create table("people", [primary_key: false]) do
      add :id, :binary_id, primary_key: true
      add :uco, :string
      add :isic, :string
      add :description, :string
    end

    create unique_index(
      "people",
      [:isic]
    )
  end
end
