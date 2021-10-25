defmodule Absolventenfeier.Repo.Migrations.AddSuffixToEvent do
  use Ecto.Migration

  def change do
    alter table ("events") do
      add(:suffix, :string)
    end
  end
end
