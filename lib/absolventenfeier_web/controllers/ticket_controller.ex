defmodule AbsolventenfeierWeb.TicketController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Events.Pretix.{Ticket}
  alias Absolventenfeier.Users.User

  def new(conn, %{"event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        ticket_changeset = Ticket.change_ticket()

        render(conn, "new.html",
          event_id: event_id,
          changeset: ticket_changeset,
          action: ticket_path(conn, :create)
        )

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    ticket = Ticket.get_ticket(id)

    case user.role do
      :admin ->
        ticket_changeset =
          id
          |> Ticket.get_ticket()
          |> Ticket.change_ticket(%{})

        render(conn, "edit.html",
          event_id: ticket.event_id,
          changeset: ticket_changeset,
          action: ticket_path(conn, :update, id)
        )

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def create(conn, %{"ticket" => ticket}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Ticket.create_ticket(ticket) do
          {:ok, ticket} ->
            conn
            |> put_flash(:info, gettext("Creating ticket successful!"))
            |> redirect(to: event_path(conn, :edit, ticket.event_id))

          {:error, changeset} ->
            conn
            |> put_flash(:error, gettext("Error while creating ticket!"))
            |> render("new.html",
              event_id: ticket["event_id"],
              changeset: changeset,
              action: ticket_path(conn, :create)
            )
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "ticket" => ticket}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        case Ticket.update_ticket(id, ticket) do
          {:ok, ticket} ->
            conn
            |> put_flash(:info, gettext("Updating ticket successful!"))
            |> redirect(to: event_path(conn, :edit, ticket.event_id))

          {:error, changeset} ->
            conn
            |> put_flash(:error, gettext("Error while updating ticket!"))
            |> render("edit.html",
              event_id: ticket["event_id"],
              changeset: changeset,
              action: ticket_path(conn, :update, id)
            )
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        ticket = Ticket.get_ticket(id)

        case Ticket.delete_ticket(ticket) do
          {:ok, ticket} ->
            conn
            |> put_flash(:info, gettext("Deleting ticket successful!"))
            |> redirect(to: event_path(conn, :edit, ticket.event_id))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, gettext("Error while deleting ticket!"))
            |> redirect(to: event_path(conn, :edit, ticket.event_id))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end
end
