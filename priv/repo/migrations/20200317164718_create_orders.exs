defmodule Absolventenfeier.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :event_id, references(:events, type: :uuid, on_delete: :delete_all)
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create table(:order_positions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add(:count, :integer)

      add :ticket_id, references(:tickets, type: :uuid)
      add :order_id, references(:orders, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
