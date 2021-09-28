defmodule Absolventenfeier.Event.Term do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "terms" do
    field(:type, TermType, default: :summer_term)
    field(:year, :integer)

    has_many(:events, Absolventenfeier.Event, on_replace: :delete)
  end

  @doc false
  def changeset(exam, attrs) do
    exam
    |> cast(attrs, [:type, :year])
    |> validate_required([:type, :year])
  end
end
