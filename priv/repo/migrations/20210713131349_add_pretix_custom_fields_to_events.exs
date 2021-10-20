defmodule Absolventenfeier.Repo.Migrations.AddPretixCustomFieldsToEvents do
  use Ecto.Migration

  def change do
    alter table("events") do
      remove :date_of_payments, :date
      add :pretix_event_slug, :string
    end
  end
end
