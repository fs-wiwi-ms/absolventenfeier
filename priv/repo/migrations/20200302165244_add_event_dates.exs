defmodule Absolventenfeier.Repo.Migrations.AddEventDates do
  use Ecto.Migration

  def change do
    alter table("events") do
      add :date_of_event, :utc_datetime, null: true
      add :date_of_registration, :utc_datetime, null: true
      add :date_of_tickets, :utc_datetime, null: true
    end
  end
end
