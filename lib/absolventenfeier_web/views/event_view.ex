defmodule AbsolventenfeierWeb.EventView do
  use AbsolventenfeierWeb, :view

  alias Absolventenfeier.Event
  alias Absolventenfeier.Event.Registration

  def user_registerd_for_event(event, user) do
    Event.user_registerd_for_event(event.id, user.id)
  end
end
