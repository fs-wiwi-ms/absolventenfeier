defmodule Absolventenfeier.Repo.Migrations.ChangeEventFromDatetimeToDate do
  use Ecto.Migration

  def change do
    alter table("events") do
      modify :date_of_event, :date, null: false
    end
  end
end
