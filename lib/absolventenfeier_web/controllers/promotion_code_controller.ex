defmodule AbsolventenfeierWeb.PromotionCodeController do
  use AbsolventenfeierWeb, :controller

  alias Absolventenfeier.Ticketing.{PromotionCode, Promotion}

  def create(conn, %{"promotion_code" => promotion_code, "order_id" => order_id}) do
    promotion = Promotion.get_promotion_by_name("MLP")

    promotion =
      if !promotion do
        {:ok, promotion} = Promotion.create_promotion(%{name: "MLP", discount: 5.0})
        promotion
      else
        promotion
      end

    promotion_code =
      promotion_code
      |> Map.put("order_id", order_id)
      |> Map.put("promotion_id", promotion.id)

    case PromotionCode.create_promotion_code(promotion_code) do
      {:ok, promotion_code} ->
        conn
        |> put_flash(:info, gettext("Promotion code accepted!"))
        |> redirect(to: order_payment_path(conn, :new, promotion_code.order_id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Error while checking promotion code!"))
        |> redirect(to: order_payment_path(conn, :new, promotion_code.order_id))
    end
  end

  def delete(conn, %{"id" => id}) do
    promotion_code = PromotionCode.get_promotion_code(id)

    case PromotionCode.delete_promotion_code(promotion_code) do
      {:ok, promotion_code} ->
        conn
        |> put_flash(:info, gettext("Deleting promotion code successful!"))
        |> redirect(to: order_payment_path(conn, :new, promotion_code.order_id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Error while deleting promotion code!"))
        |> redirect(to: order_payment_path(conn, :new, promotion_code.order_id))
    end
  end
end
