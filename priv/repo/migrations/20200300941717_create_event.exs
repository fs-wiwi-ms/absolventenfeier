defmodule Absolventenfeier.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :published, :boolean

      add :term_id, references(:terms, type: :uuid)

      timestamps()
    end
  end
end
