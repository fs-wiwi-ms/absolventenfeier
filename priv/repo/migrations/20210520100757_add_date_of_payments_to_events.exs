defmodule Absolventenfeier.Repo.Migrations.AddDateOfPaymentsToEvents do
  use Ecto.Migration

  def change do
    alter table("events") do
      add :date_of_payments, :date
    end
  end
end
