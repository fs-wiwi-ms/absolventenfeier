defmodule AbsolventenfeierWeb.EventView do
  use AbsolventenfeierWeb, :view

  alias Absolventenfeier.Event
  alias Absolventenfeier.Event.Registration
  alias Absolventenfeier.Ticketing.Order

  def user_registerd_for_event(event, user) do
    Event.user_registerd_for_event(event.id, user.id)
  end

  def user_ordered_for_event(event, user) do
    Order.user_ordered_for_event(event.id, user.id)
  end

  def get_event_state(event) do
    Event.get_event_state(event)
  end

  def get_payment_status_for_order(order) do
    Order.get_payment_status_for_order(order)
  end
end
