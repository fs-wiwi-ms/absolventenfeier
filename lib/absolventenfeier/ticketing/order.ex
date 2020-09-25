defmodule Absolventenfeier.Ticketing.Order do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.Ticketing.{Order, OrderPosition, Payment}
  alias Absolventenfeier.{User, Event, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orders" do
    field :sum, :integer, default: 0, virtual: true

    belongs_to(:event, Absolventenfeier.Event)
    belongs_to(:user, Absolventenfeier.User)

    has_many(:order_positions, Absolventenfeier.Ticketing.OrderPosition)
    has_one(:payment, Absolventenfeier.Ticketing.Payment)

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [])
    |> put_assoc(:user, attrs["user"] || order.user)
    |> put_assoc(:event, attrs["event"] || order.event)
    |> put_assoc(:order_positions, attrs["order_positions"] || order.order_positions)
  end

  def changeset_edit(order, attrs) do
    order
    |> cast(attrs, [])
    |> put_assoc(:user, attrs["user"] || order.user)
    |> put_assoc(:event, attrs["event"] || order.event)
    |> cast_assoc(:order_positions,
      with: &Absolventenfeier.Ticketing.OrderPosition.changeset_create/2
    )
  end

  # -----------------------------------------------------------------
  # -- Order
  # -----------------------------------------------------------------

  def get_orders() do
    Order
    |> preload([:event, :user, :payment, order_positions: :ticket])
    |> Repo.all()
  end

  def get_order(id) do
    Order
    |> preload([:event, :user, :payment, order_positions: :ticket])
    |> Repo.get(id)
    |> calculate_sum
  end

  def create_order(order_params) do
    user = User.get_user(order_params["user_id"])
    event = Event.get_event(order_params["event_id"])

    order_positions =
      order_params["order_positions"]
      |> Enum.map(fn {_key, value} -> value end)

    order_params =
      order_params
      |> Map.drop(["event_id", "user_id", "order_positions"])
      |> Map.put("event", event)
      |> Map.put("user", user)
      |> Map.put("order_positions", order_positions)

    %Order{}
    |> Repo.preload([:event, :user, :order_positions, :payment])
    |> Order.changeset_edit(order_params)
    |> Repo.insert()
  end

  def update_order(order_id, order_params) do
    order =
      Order
      |> Repo.get(order_id)
      |> Repo.preload([:event, :user, :order_positions, :payment])

    user = User.get_user(order_params["user_id"])
    event = Event.get_event(order_params["event_id"])

    order_params =
      order_params
      |> Map.drop(["event_id", "user_id"])
      |> Map.put("event", event)
      |> Map.put("user", user)

    order
    |> Order.changeset_edit(order_params)
    |> Repo.update()
  end

  def delete_order(order) do
    Repo.delete(order)
  end

  def create_order_params_for_event(event) do
    order_positions =
      Enum.map(event.tickets, fn ticket ->
        OrderPosition.prepare_changeset(ticket)
      end)

    %{}
    |> Map.put("event", event)
    |> Map.put("order_positions", order_positions)
  end

  def change_order(order \\ %Order{}, attrs) do
    order
    |> Repo.preload([:event, :user, :order_positions])
    |> Order.changeset(attrs)
  end

  def user_ordered_for_event(event_id, user_id) do
    Order
    |> where(event_id: ^event_id)
    |> where(user_id: ^user_id)
    |> preload([:event, :user, :payment])
    |> Repo.one()
  end

  def get_payment_status_for_order(order) do
    order = Repo.preload(order, [:payment])

    Payment.get_payment_status(order.payment)
  end

  defp calculate_sum(order) do
    sum =
      Enum.reduce(order.order_positions, 0, fn op, temp_sum ->
        temp_sum + op.ticket.price * op.count
      end)

    Map.put(order, :sum, sum)
  end
end
