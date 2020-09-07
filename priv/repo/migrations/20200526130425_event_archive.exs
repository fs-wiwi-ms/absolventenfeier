defmodule Absolventenfeier.Repo.Migrations.EventArchive do
  use Ecto.Migration

  def up do
    alter table("events") do
      add :archived, :boolean, default: false
    end

    # to apply the alter command to the database
    flush()

    repo().update_all("events", set: [archived: false])
  end

  def down do
    alter table("events") do
      remove :archived
    end
  end
end
