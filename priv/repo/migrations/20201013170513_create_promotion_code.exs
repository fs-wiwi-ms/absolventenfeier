defmodule Absolventenfeier.Repo.Migrations.CreatePromotionCode do
  use Ecto.Migration

  def change do
    create table("promotion_codes", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:code, :string)

      add(:order_id, references(:orders, on_delete: :delete_all, type: :uuid))
      add(:promotion_id, references(:promotions, on_delete: :delete_all, type: :uuid))

      timestamps()
    end
  end
end
