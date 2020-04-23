defmodule AbsolventenfeierWeb.PaymentView do
  use AbsolventenfeierWeb, :view

  alias Absolventenfeier.Ticketing.Payment

  def get_payment_status(payment) do
    Payment.get_payment_status(payment)
  end
end
