defmodule Absolventenfeier.Repo.Migrations.UpdateEnum do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute("ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'mollie'")
  end

  def down do
  end
end
