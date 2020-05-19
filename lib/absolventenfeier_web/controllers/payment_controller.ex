defmodule AbsolventenfeierWeb.PaymentController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Ticketing.{Order, Payment}

  require Logger

  def webhook(conn, %{"id" => mollie_id}) do
    case Payment.refresh_payment_by_mollie_id(mollie_id) do
      {:ok, _payment} ->
        json(conn, :ok)

      {:error, changeset} ->
        Logger.error("Could not update payment: #{inspect(changeset)}")
        json(conn, :ok)
    end
  end

  def new(conn, %{"order_id" => order_id}) do
    order = Order.get_order(order_id)

    case Payment.create_payment_from_order(order) do
      {:ok, payment} ->
        conn
        |> redirect(external: payment.webhook_url)

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Error while creating payment!"))
        |> redirect(to: event_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    payment =
      Payment.get_payment(id)

    conn
    |> redirect(to: event_path(conn, :index))
  end
end
