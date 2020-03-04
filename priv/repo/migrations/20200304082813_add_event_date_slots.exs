defmodule Absolventenfeier.Repo.Migrations.AddEventDateSlots do
  use Ecto.Migration

  def change do
    alter table("events") do
      add :start_of_registration, :utc_datetime, null: true
      add :start_of_tickets, :utc_datetime, null: true
    end
  end
end
