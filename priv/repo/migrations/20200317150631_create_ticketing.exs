defmodule Absolventenfeier.Repo.Migrations.CreateTicketing do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :uuid, primary_key: true

      add(:name, :string)
      add(:price, :float)
      add(:count, :integer)
      add(:max_per_user, :integer)

      add :event_id, references(:events, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
