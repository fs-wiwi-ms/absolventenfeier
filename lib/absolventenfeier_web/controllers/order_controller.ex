defmodule AbsolventenfeierWeb.OrderController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Ticketing.{Order}
  alias Absolventenfeier.{User, Event}

  def new(conn, %{"event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    event = Event.get_event(event_id, [:tickets])

    case Event.get_event_state(event) do
      :ticketing_open ->
        order_changeset =
          event
          |> Order.create_order_params_for_event()
          |> Order.change_order()

        render(conn, "new.html",
          user: user,
          event: event,
          changeset: order_changeset,
          action: order_path(conn, :create)
        )

      other ->
        conn
        |> put_flash(:error, gettext("Ticketing already closed!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    order = Order.get_order(id, [:event, :user, order_positions: :ticket])
    event = Event.get_event(order.event_id, [:tickets])

    case Event.get_event_state(event) do
      :ticketing_open ->
        order_changeset = Order.change_order(order, %{})

        render(conn, "edit.html",
          user: user,
          event: event,
          changeset: order_changeset,
          action: order_path(conn, :update, id)
        )

      other ->
        conn
        |> put_flash(:error, gettext("Ticketing closed!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def create(conn, %{"order" => order}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    event = Event.get_event(order["event_id"], [:tickets])

    case Order.create_order(order) do
      {:ok, _order} ->
        conn
        |> put_flash(:info, gettext("Creating order successful!"))
        |> redirect(to: event_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Error while creating order!"))
        |> render("new.html",
          user: user,
          event: event,
          changeset: changeset,
          action: event_order_path(conn, :new, event.id)
        )
    end
  end

  def update(conn, %{"id" => id, "order" => order}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    event = Event.get_event(order["event_id"], [:tickets])

    case Order.update_order(id, order) do
      {:ok, _order} ->
        conn
        |> put_flash(:info, gettext("Updating order successful!"))
        |> redirect(to: event_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Error while updating order!"))
        |> render("edit.html",
          user: user,
          event: event,
          changeset: changeset,
          action: order_path(conn, :edit, id)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    _user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    order = Order.get_order(id)

    case Event.get_event_state(order.event) do
      :ticketing_open ->
        case Order.delete_order(order) do
          {:ok, _order} ->
            conn
            |> put_flash(:info, gettext("Deleting order successful!"))
            |> redirect(to: event_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while deleting order!"))
            |> redirect(to: event_path(conn, :index))
        end

      other ->
        conn
        |> put_flash(:error, gettext("Ticketing already closed!"))
        |> redirect(to: event_path(conn, :index))
    end
  end
end
