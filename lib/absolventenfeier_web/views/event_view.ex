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

  def step(tag_color, state, icon, title, description) do
    content_tag :div, class: "step-item #{tag_color} #{state}" do
      [content_tag :div, class: "step-marker" do
        content_tag :span, class: "icon" do
          content_tag :i, "", class: "#{icon}"
        end
      end,
      content_tag :div, class: "step-details" do
        [content_tag :p, class: "step-title" do
          title
        end,
        content_tag :p do
          description
        end]
      end]
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
      n when n in [:upcoming_event, :running_event, :expired_event,:ticketing_closed, :ticketing_open] ->
        if user_registerd_for_event(event, user) do
          4
        else
          5
        end
      _ ->
        nil
    end
  end

  def ticketing_step(event,user) do
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
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              6
            _ ->
              5
          end
        else
          3
        end
      n when n in [:upcoming_event, :running_event, :expired_event] ->
        if user_registerd_for_event(event, user) do
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              7
            _ ->
              4
          end
        else
          3
        end
      _ ->
        nil
    end
  end

  def payment_step(event, user) do
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
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  3
                :paid ->
                  4
                :error ->
                  5
                :none ->
                  6
              end
            _ ->
              1
          end
        else
          2
        end
      n when n in [:upcoming_event, :running_event, :expired_event] ->
        if user_registerd_for_event(event, user) do
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  3
                :paid ->
                  4
                :error ->
                  5
                :none ->
                  6
              end
            _ ->
              2
          end
        else
          2
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
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  nil
                :paid ->
                  3
                :error ->
                  nil
                :none ->
                  nil
              end
            _ ->
              1
          end
        else
          2
        end
      :upcoming_event ->
        if user_registerd_for_event(event, user) do
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  6
                :paid ->
                  3
                :error ->
                  nil
                :none ->
                  6
              end
            _ ->
              2
          end
        else
          2
        end
      :running_event ->
        if user_registerd_for_event(event, user) do
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  nil
                :paid ->
                  4
                :error ->
                  nil
                :none ->
                  nil
              end
            _ ->
              2
          end
        else
          2
        end
      :expired_event ->
        if user_registerd_for_event(event, user) do
          case user_ordered_for_event(event, user) do
            %Order{} = order ->
              case get_payment_status_for_order(order) do
                :open ->
                  5
                :paid ->
                  5
                :error ->
                  5
                :none ->
                  5
              end
            _ ->
              2
          end
        else
          2
        end
      _ ->
        nil
    end
  end
end
