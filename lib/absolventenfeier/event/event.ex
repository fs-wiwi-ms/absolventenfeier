defmodule Absolventenfeier.Event do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.{Event, Repo, User}

  alias Absolventenfeier.Event.{
    Term,
    Registration
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "events" do
    field(:published, :boolean, default: false)
    field(:archived, :boolean, default: false)
    field(:date_of_event, :date, default: nil)
    field(:date_of_registration, :utc_datetime, default: nil)
    field(:date_of_tickets, :utc_datetime, default: nil)
    field(:start_of_registration, :utc_datetime, default: nil)
    field(:start_of_tickets, :utc_datetime, default: nil)

    belongs_to(:term, Absolventenfeier.Event.Term)
    has_many(:registrations, Absolventenfeier.Event.Registration, on_delete: :nothing)
    has_many(:tickets, Absolventenfeier.Ticketing.Ticket, on_delete: :nothing)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :published,
      :archived,
      :date_of_event,
      :date_of_registration,
      :date_of_tickets,
      :start_of_registration,
      :start_of_tickets
    ])
    |> put_assoc(:registrations, attrs["registrations"] || event.registrations)
    |> put_assoc(:term, attrs["term"] || event.term)
    |> put_assoc(:tickets, attrs["tickets"] || event.tickets)
  end

  # -----------------------------------------------------------------
  # -- Event
  # -----------------------------------------------------------------

  def get_events_for_registration() do
    Event
    |> preload([:registrations, :term, :tickets])
    |> where([e], e.published)
    |> order_by([e, r], e.date_of_event)
    |> Repo.all()
  end

  # def get_events_for_user(user_id) do
  #   Event
  #   |> join(:left, [e], r in assoc(e, :registrations))
  #   |> where([e, r], r.user_id == ^user_id)
  #   |> where([e, r], e.published)
  #   |> order_by([e, r], e.date_of_event)
  #   |> Repo.all()
  # end

  def get_events() do
    Event
    |> preload([:registrations, :term, :tickets])
    |> where([e], not e.archived)
    |> order_by([e, r], e.date_of_event)
    |> Repo.all()
  end

  def get_event(id, preload \\ []) do
    Event
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def create_event(event_params) do
    term = Event.get_term(event_params["term_id"])

    event_params =
      event_params
      |> Map.drop(["term_id"])
      |> Map.put("term", term)
      |> Map.put("registrations", [])
      |> Map.put("tickets", [])

    %Event{}
    |> Repo.preload([:term, :registrations, :tickets])
    |> Event.changeset(event_params)
    |> Repo.insert()
  end

  def update_event(event_id, event_params) do
    event =
      Event
      |> Repo.get(event_id)
      |> Repo.preload([:term, :registrations, :tickets])

    term = Event.get_term(event_params["term_id"])

    event_params =
      event_params
      |> Map.drop(["term_id"])
      |> Map.put("term", term)

    event
    |> Event.changeset(event_params)
    |> Repo.update()
  end

  def make_event_private(event_id) do
    event =
      Event
      |> Repo.get(event_id)
      |> Repo.preload([:term, :registrations, :tickets])

    event
    |> Event.changeset(%{"published" => false})
    |> Repo.update()
  end

  def archive(event_id) do
    event =
      Event
      |> Repo.get(event_id)
      |> Repo.preload([:term, :registrations, :tickets])

    event
    |> Event.changeset(%{"archived" => true})
    |> Repo.update()
  end

  def publish_event(event_id) do
    event =
      Event
      |> Repo.get(event_id)
      |> Repo.preload([:term, :registrations, :tickets])

    event
    |> Event.changeset(%{"published" => true})
    |> Repo.update()
  end

  def delete_event(event) do
    Repo.delete(event)
  end

  def change_event(event \\ %Event{}, attrs \\ %{}) do
    event
    |> Repo.preload([:term, :registrations, :tickets])
    |> Event.changeset(attrs)
  end

  def get_event_state(%{published: false}), do: :private

  def get_event_state(event) do
    case {Timex.compare(event.start_of_registration, Timex.now()),
          Timex.compare(event.date_of_registration, Timex.now()),
          Timex.compare(event.start_of_tickets, Timex.now()),
          Timex.compare(event.date_of_tickets, Timex.now()),
          Timex.compare(event.date_of_event, Timex.now(), :day)} do
      {1, 1, _, _, 1} -> :registration_closed
      {-1, 1, _, _, 1} -> :registration_open
      {_, _, 1, 1, 1} -> :ticketing_closed
      {_, _, -1, 1, 1} -> :ticketing_open
      {-1, -1, -1, -1, 1} -> :upcoming_event
      {-1, -1, -1, -1, 0} -> :running_event
      {_, _, _, _, -1} -> :expired_event
    end
  end

  # -----------------------------------------------------------------
  # -- Registration
  # -----------------------------------------------------------------
  def get_registrations_for_event(event_id) do
    Registration
    |> where(event_id: ^event_id)
    |> preload([:user, :event])
    |> Repo.all()
  end

  def user_registerd_for_event(event_id, user_id) do
    Registration
    |> where(event_id: ^event_id)
    |> where(user_id: ^user_id)
    |> Repo.one()
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

    case user_registerd_for_event(event.id, user.id) do
      %Registration{} = registration ->
        {:already_registered, registration}

      nil ->
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
  end

  def update_registration(registration, registration_params) do
    registration
    |> Registration.changeset(registration_params)
    |> Repo.update()
  end

  def change_registration(
        registration \\ %Registration{},
        attrs
      ) do
    registration
    |> Repo.preload([:user, :event])
    |> Registration.changeset(attrs)
  end

  def delete_registration(registration) do
    Repo.delete(registration)
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
