defmodule Absolventenfeier.Event.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Absolventenfeier.Event
  alias Absolventenfeier.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "registration" do
    belongs_to(:user, Absolventenfeier.User)
    belongs_to(:event, Absolventenfeier.Event)

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> put_assoc(:event, attrs["event"] || registration.event)
    |> put_assoc(:user, attrs["user"] || registration.user)
  end
end
