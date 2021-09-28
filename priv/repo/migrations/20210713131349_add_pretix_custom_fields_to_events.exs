defmodule Absolventenfeier.Repo.Migrations.AddPretixCustomFieldsToEvents do
  use Ecto.Migration

  def change do
    alter table("events") do
      remove :date_of_payments, :date
      add :voucher_code, :string
      add :pretix_shop_url, :string
    end
  end
end
