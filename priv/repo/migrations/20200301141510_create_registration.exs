defmodule Absolventenfeier.Repo.Migrations.CreateRegistration do
  use Ecto.Migration

  def up do
    DegreeType.create_type()
    CourseType.create_type()

    create table(:registrations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, type: :uuid)
      add :event_id, references(:events, type: :uuid)

      add :degree, :degree_type
      add :course, :course_type

      timestamps()
    end

    # create table("game_users", primary_key: false) do
    #   add :user_id, references(:user, type: :string), primary_key: true

    #   add :game_id, references(:game, type: :uuid), primary_key: true
    # end
  end

  def down do
    drop table(:registrations)

    DegreeType.drop_type()
    CourseType.drop_type()
  end
end
