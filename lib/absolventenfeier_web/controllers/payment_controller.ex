defmodule AbsolventenfeierWeb.PaymentController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Ticketing.{Order, Payment, PromotionCode}

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
    promotion_codes = PromotionCode.get_promotion_code_by_order_id(order_id)
    payment_changeset = Payment.change_bank_transfer_payment_from_order(order)
    changeset = PromotionCode.change_promotion_code()

    render(conn, "new.html", %{
      changeset: changeset,
      action: order_promotion_code_path(conn, :create, order_id),
      promotion_codes: promotion_codes,
      order: order,
      payment_changeset: payment_changeset,
      payment_action: order_payment_path(conn, :create, order.id)
    })
  end

  def create(conn, %{"payment" => _payment, "order_id" => order_id}) do
    order = Order.get_order(order_id)

    case Payment.create_payment(order) do
      {:ok, payment} ->
        conn
        |> put_flash(:info, gettext("Creating payment successful!"))
        |> redirect(to: payment_path(conn, :show, payment.id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Error while creating payment!"))
        |> redirect(to: order_payment_path(conn, :new, order.id))
    end
  end

  def show(conn, %{"id" => id}) do
    payment = Payment.get_payment(id)

    render(conn, "show.html", %{payment: payment})
  end
end
