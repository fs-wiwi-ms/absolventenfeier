defmodule Absolventenfeier.Ticketing.Ticket do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.{Event, Repo}
  alias Absolventenfeier.Ticketing.{Ticket}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tickets" do
    field(:name, :string)
    field(:price, :float, default: 0)
    field(:count, :integer, default: -1)
    field(:max_per_user, :integer, default: -1)

    belongs_to(:event, Event)

    timestamps()
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:name, :price, :count, :max_per_user])
    |> put_assoc(:event, attrs["event"] || ticket.event)
  end

  # -----------------------------------------------------------------
  # -- Ticket
  # -----------------------------------------------------------------

  def get_tickets() do
    Ticket
    |> preload([:event])
    |> Repo.all()
  end

  def get_ticket(id, preload \\ []) do
    Ticket
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def create_ticket(ticket_params) do
    event = Event.get_event(ticket_params["event_id"])

    ticket_params =
      ticket_params
      |> Map.drop(["event_id"])
      |> Map.put("event", event)

    %Ticket{}
    |> Repo.preload([:event])
    |> Ticket.changeset(ticket_params)
    |> Repo.insert()
  end

  def update_ticket(ticket_id, ticket_params) do
    ticket =
      Ticket
      |> Repo.get(ticket_id)
      |> Repo.preload([:event])

    event = Event.get_event(ticket_params["event_id"])

    ticket_params =
      ticket_params
      |> Map.drop(["event_id"])
      |> Map.put("event", event)

    ticket
    |> Ticket.changeset(ticket_params)
    |> Repo.update()
  end

  def delete_ticket(ticket) do
    Repo.delete(ticket)
  end

  def change_ticket(ticket \\ %Ticket{}, attrs \\ %{}) do
    ticket
    |> Repo.preload([:event])
    |> Ticket.changeset(attrs)
  end
end
