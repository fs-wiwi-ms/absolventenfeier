defmodule AbsolventenfeierWeb.RegistrationView do
  use AbsolventenfeierWeb, :view

  defp get_degree_tag(degree) do
    content_tag(
      :span,
      Gettext.dgettext(AbsolventenfeierWeb.Gettext, "enum", Atom.to_string(degree), %{}),
      class: "tag #{get_class_for_tag(degree)}"
    )
  end

  defp get_course_tag(course) do
    content_tag(
      :span,
      Gettext.dgettext(AbsolventenfeierWeb.Gettext, "enum", Atom.to_string(course), %{}),
      class: "tag #{get_class_for_tag(course)}"
    )
  end

  defp get_class_for_tag(:bachelor), do: "is-link"
  defp get_class_for_tag(:master), do: "is-danger"
  defp get_class_for_tag(:information_systems), do: "is-danger"
  defp get_class_for_tag(:economics), do: "is-info"
  defp get_class_for_tag(:business_economics), do: "is-link"
  defp get_class_for_tag(:none), do: ""
end
