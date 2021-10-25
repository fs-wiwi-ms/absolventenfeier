defmodule Absolventenfeier.Repo.Migrations.ChangeTicketsToPretixSystem do
  use Ecto.Migration

  def change do
    alter table("tickets") do
      remove :count, :integer
      remove :price, :float
      add :pretix_ticket_id, :integer
    end
  end
end
