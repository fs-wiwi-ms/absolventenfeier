defmodule AbsolventenfeierWeb.EventView do
  use AbsolventenfeierWeb, :view

  alias Absolventenfeier.Events.{Registration, Event}
  alias Absolventenfeier.Events.Pretix.{Voucher}

  def user_registerd_for_event(event, user) do
    Registration.user_registerd_for_event(event.id, user.id)
  end

  def get_vouchers_for_registration(registration) do
    Voucher.get_vouchers_for_registration(registration.id)
  end

  def pretix_host, do: System.get_env("PRETIX_HOST")


  def get_event_state(event) do
    Event.get_event_state(event)
  end

  def step(tag_color, state, icon, title, description) do
    content_tag :li, class: "steps-segment #{state}" do
      [
        content_tag :a, class: "steps-marker #{tag_color}" do
          content_tag :span, class: "icon" do
            content_tag(:i, "", class: "#{icon}")
          end
        end,
        content_tag :div, class: "steps-content" do
          [
            content_tag :p, class: "is-size-4" do
              title
            end,
            content_tag :p do
              description
            end
          ]
        end
      ]
    end
  end

  def registration_step(event, user) do
    case get_event_state(event) do
      :registration_closed ->
        1

      :registration_open ->
        if user_registerd_for_event(event, user) do
          2
        else
          3
        end

      n
      when n in [
             :upcoming_event,
             :running_event,
             :expired_event,
             :ticketing_closed,
             :ticketing_open
           ] ->
        if user_registerd_for_event(event, user) do
          4
        else
          5
        end

      _ ->
        nil
    end
  end

  def ticketing_step(event, user) do
    case get_event_state(event) do
      n when n in [:registration_closed, :registration_open] ->
        1

      :ticketing_closed ->
        if user_registerd_for_event(event, user) do
          2
        else
          3
        end

      :ticketing_open ->
        if user_registerd_for_event(event, user) do
          4
        else
          3
        end

      n when n in [:upcoming_event, :running_event, :expired_event] ->
        if user_registerd_for_event(event, user) do
          5
        else
          3
        end

      _ ->
        nil
    end
  end

  def graduation_step(event, user) do
    case get_event_state(event) do
      n when n in [:registration_closed, :registration_open] ->
        1

      :ticketing_closed ->
        if user_registerd_for_event(event, user) do
          1
        else
          2
        end

      :ticketing_open ->
        if user_registerd_for_event(event, user) do
          3
        else
          2
        end

      n when n in [:upcoming_event, :running_event] ->
        if user_registerd_for_event(event, user) do
          4
        else
          2
        end

      :expired_event ->
        if user_registerd_for_event(event, user) do
          5
        else
          2
        end

      _ ->
        nil
    end
  end
end
