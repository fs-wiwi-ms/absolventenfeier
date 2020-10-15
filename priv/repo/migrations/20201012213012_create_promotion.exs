defmodule Absolventenfeier.Repo.Migrations.CreatePromotion do
  use Ecto.Migration

  def change do
    create table("promotions", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:discount, :float)

      timestamps()
    end
  end
end
