defmodule Absolventenfeier.Repo.Migrations.AddUser do
  use Ecto.Migration

  def up do
    DegreeType.create_type()
    CourseType.create_type()
    UserRole.create_type()

    create table("user", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :fore_name, :string
      add :last_name, :string
      add :matriculation_number, :string

      add :degree, :degree_type
      add :course, :course_type
      add :role, :user_role

      add :password_hash, :string

      timestamps()
    end

    create unique_index("user", :email)

    # create table("game_users", primary_key: false) do
    #   add :user_id, references(:user, type: :string), primary_key: true

    #   add :game_id, references(:game, type: :uuid), primary_key: true
    # end
  end

  def down do
    drop table(:user)

    DegreeType.drop_type()
    CourseType.drop_type()
    UserRole.drop_type()
  end
end
