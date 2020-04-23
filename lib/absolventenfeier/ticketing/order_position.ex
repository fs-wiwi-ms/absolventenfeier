defmodule Absolventenfeier.Ticketing.OrderPosition do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.Ticketing.{Ticket, Order, OrderPosition}
  alias Absolventenfeier.{Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "order_positions" do
    field(:count, :integer, default: 1)

    belongs_to(:ticket, Ticket)
    belongs_to(:order, Order)

    timestamps()
  end

  @doc false
  def changeset(oder_position, attrs) do
    oder_position
    |> cast(attrs, [
      :count
    ])
    |> put_assoc(:order, attrs["order"] || oder_position.order)
    |> put_assoc(:ticket, attrs["ticket"] || oder_position.ticket)
  end

  def changeset_create(oder_position, attrs) do
    oder_position
    |> cast(attrs, [
      :count,
      :ticket_id
    ])
  end

  def prepare_changeset(ticket) do
    %OrderPosition{}
    |> Repo.preload([:order, :ticket])
    |> changeset(%{"ticket" => ticket})
  end
end
