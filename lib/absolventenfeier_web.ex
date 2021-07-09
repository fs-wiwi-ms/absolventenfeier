defmodule AbsolventenfeierWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AbsolventenfeierWeb, :controller
      use AbsolventenfeierWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: AbsolventenfeierWeb

      import Plug.Conn
      import AbsolventenfeierWeb.Gettext
      import AbsolventenfeierWeb.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/absolventenfeier_web/templates",
        namespace: AbsolventenfeierWeb

      use Appsignal.Phoenix.View

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use Number

      import AbsolventenfeierWeb.ErrorHelpers
      import AbsolventenfeierWeb.Gettext
      import AbsolventenfeierWeb.Router.Helpers

      def error_label(changeset, field) do
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        case Enum.find(errors, fn {key, value} -> key == field end) do
          {field, errors} ->
            content_tag(:p, Enum.join(errors, ", "), class: "help is-danger")

          nil ->
            nil
        end
      end

      def get_user(conn) do
        case conn.assigns[:session] do
          nil ->
            nil

          session ->
            Absolventenfeier.User.get_user(session.user_id)
        end
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AbsolventenfeierWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
