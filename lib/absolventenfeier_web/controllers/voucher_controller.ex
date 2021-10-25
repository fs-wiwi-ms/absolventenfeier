defmodule AbsolventenfeierWeb.VoucherController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Events.Pretix.{Ticket, Voucher, Api}
  alias Absolventenfeier.Users.User
  alias Absolventenfeier.Events.Event

  def batch_create(conn, %{"ticket_id" => ticket_id, "event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        event = Event.get_event(event_id)
        ticket = Ticket.get_ticket(ticket_id)

        case Voucher.batch_create_voucher(event, ticket) do
          {:ok, _multi} ->
            conn
            |> put_flash(:info, gettext("Creating voucher codes successful!"))
            |> redirect(to: event_path(conn, :edit, event.id))

          {:error, _multi} ->
            conn
            |> put_flash(:error, gettext("Error while creating voucher codes!"))
            |> redirect(to: event_path(conn, :edit, event.id))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def batch_pretix_sync(conn, %{"event_id" => event_id}) do
    user =
      conn
      |> get_session(:user_id)
      |> User.get_user()

    case user.role do
      :admin ->
        event = Event.get_event(event_id)

        with vouchers <- Voucher.get_not_synced_vouchers_for_event(event.id),
             {:ok, pretix_vouchers} <- Api.create_voucher_code(event, vouchers),
             {:ok, _multi} <-
               Voucher.batch_update_vouchers_with_pretix_ids(vouchers, pretix_vouchers) do
          conn
          |> put_flash(:info, gettext("Syncing voucher codes successful!"))
          |> redirect(to: event_path(conn, :edit, event.id))
        else
          {:error, _multi} ->
            conn
            |> put_flash(:error, gettext("Error while creating voucher codes!"))
            |> redirect(to: event_path(conn, :edit, event.id))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("This action is permitted!"))
        |> redirect(to: event_path(conn, :index))
    end
  end
end
