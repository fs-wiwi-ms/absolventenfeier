defmodule Absolventenfeier.Repo.Migrations.UpdateCourseTypes do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute "ALTER TYPE course_type ADD VALUE IF NOT EXISTS 'interdisciplinary_studies'"
  end

  def down do
  end
end
