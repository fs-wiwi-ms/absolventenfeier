defmodule Absolventenfeier.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Absolventenfeier.{Repo}

  alias Absolventenfeier.Events.{
    Event,
    Term
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
    field(:pretix_event_slug, :string)
    field(:suffix, :string)

    belongs_to(:term, Absolventenfeier.Events.Term)
    has_many(:registrations, Absolventenfeier.Events.Registration, on_delete: :nothing)
    has_many(:tickets, Absolventenfeier.Events.Pretix.Ticket, on_delete: :nothing)
    has_many(:vouchers, Absolventenfeier.Events.Pretix.Voucher, on_delete: :nothing)

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
      :start_of_tickets,
      :pretix_event_slug
    ])
    |> put_assoc(:registrations, attrs["registrations"] || event.registrations)
    |> put_assoc(:term, attrs["term"] || event.term)
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
    term = Term.get_term(event_params["term_id"])

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

    term = Term.get_term(event_params["term_id"])

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
      # pre-registration
      {1, 1, _, _, 1} -> :registration_closed
      # registration-period
      {-1, 1, _, _, 1} -> :registration_open
      # pre-ticketing
      {_, _, 1, 1, 1} -> :ticketing_closed
      # ticketing-period
      {_, _, -1, 1, 1} -> :ticketing_open
      # after-ticketing
      {-1, -1, -1, -1, 1} -> :upcoming_event
      {-1, -1, -1, -1, 0} -> :running_event
      {_, _, _, _, -1} -> :expired_event
    end
  end
end
