defmodule Absolventenfeier.Repo.Migrations.AddPayment do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :mollie_id, :string
      add :status, :string
      add :method, :string
      add :amount_value, :string
      add :amount_currency, :string
      add :description, :string
      add :webhook_url, :string

      add :order_id, references(:orders, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
