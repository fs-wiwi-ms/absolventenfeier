defmodule Absolventenfeier.Repo.Migrations.CreateTermStructure do
  use Ecto.Migration

  def up do
    TermType.create_type()

    create table(:terms, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:year, :integer)
      add(:type, :term_type)
    end
  end

  def down do
    drop table(:terms)

    TermType.drop_type()
  end
end
