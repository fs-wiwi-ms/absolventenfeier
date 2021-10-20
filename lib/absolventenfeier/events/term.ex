defmodule Absolventenfeier.Events.Term do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Absolventenfeier.{Repo}

  alias Absolventenfeier.Events.{
    Term
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "terms" do
    field(:type, TermType, default: :summer_term)
    field(:year, :integer)

    has_many(:events, Absolventenfeier.Events.Event, on_replace: :delete)
  end

  @doc false
  def changeset(exam, attrs) do
    exam
    |> cast(attrs, [:type, :year])
    |> validate_required([:type, :year])
  end

  # -----------------------------------------------------------------
  # -- Term
  # -----------------------------------------------------------------

  def get_terms() do
    Term
    |> Repo.all()
  end

  def get_term(id) do
    Term
    |> Repo.get(id)
  end

  def get_term_by_year_and_type(year, type) do
    Term
    |> Repo.get_by(type: type, year: year)
  end

  def create_term(term_params) do
    %Term{}
    |> Term.changeset(term_params)
    |> Repo.insert()
  end

  def update_term(term, term_params) do
    term
    |> Term.changeset(term_params)
    |> Repo.update()
  end

  def delete_term(term) do
    Repo.delete(term)
  end
end
