defmodule Absolventenfeier.Event.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "registrations" do
    field(:degree, DegreeType, default: :none)
    field(:course, CourseType, default: :none)

    field(:street, :string)
    field(:house_number, :string)
    field(:zip_code, :integer)
    field(:city, :string)

    belongs_to(:user, Absolventenfeier.User)
    belongs_to(:event, Absolventenfeier.Event)

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:degree, :course, :street, :house_number, :zip_code, :city])
    |> put_assoc(:event, attrs["event"] || registration.event)
    |> put_assoc(:user, attrs["user"] || registration.user)
  end
end
