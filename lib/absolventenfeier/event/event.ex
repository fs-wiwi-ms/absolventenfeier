defmodule Absolventenfeier.Event do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.Event
  alias Absolventenfeier.Event.{
    Term,
    Registration
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "event" do
    field(:published, :boolean, default: false)

    belongs_to(:term, Absolventenfeier.Event.Term)
    has_many(:registrations, Absolventenfeier.Event.Registration)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:published])
    |> put_assoc(:registrations, attrs["registrations"] || event.registrations)
    |> put_assoc(:term, attrs["term"] || event.term)
  end

  # -----------------------------------------------------------------
  # -- Event
  # -----------------------------------------------------------------

  def get_events_for_user(user_id) do
    Event
    |> join(:left, [e], r in assoc(e, :registrations))
    |> where([e, r], r.user_id == ^user_id)
    |> Repo.all()
  end

  def get_events() do
    Event
    |> Repo.all()
  end

  def get_event(id, preload \\ []) do
    Event
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def create_event(event_params) do
    users = Enum.map(event_params["user_ids"] || [], &User.get_user(&1))
    term = Term.get_term(event_params["term_id"])

    event_params =
      event_params
      |> Map.drop(["registration_ids"])
      |> Map.drop(["term_id"])
      |> Map.put("term", term)
      |> Map.put("registrations", [])

    %Event{}
    |> Repo.preload([:term, :registrations])
    |> Event.changeset(event_params)
    |> Repo.insert()
  end

  def change_event(event \\ %Event{}, attrs \\ %{}) do
    event
    |> Repo.preload([:term, :registrations])
    |> Event.changeset(attrs)
  end

  # -----------------------------------------------------------------
  # -- Registration
  # -----------------------------------------------------------------
  def get_registrations_for_event(event_id) do
    Repo.all(from s in Registration, where: s.event_id == ^event_id)
  end

  def get_registration(nil), do: nil

  def get_registration(id) do
    Registration
    |> Repo.get(id)
    |> Repo.preload([:user, :event])
  end

  def create_registration(registration_params) do
    event = get_event(registration_params["event_id"])
    user = User.get_user(registration_params["user_id"])

    registration_params =
      registration_params
      |> Map.drop(["event_id", "user_id"])
      |> Map.put("event", event)
      |> Map.put("user", user)

    %Registration{}
    |> Repo.preload([:event, :user])
    |> Registration.changeset(registration_params)
    |> Repo.insert()
  end

  def update_registration(registration, registration_params) do
    registration
    |> Registration.changeset(registration_params)
    |> Repo.update()
  end

  def change_registration(
        registration \\ %Registration{},
        attrs \\ %{}
      ) do
    registration
    |> Repo.preload([:user, :event])
    |> Registration.changeset(attrs)
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
