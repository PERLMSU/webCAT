defmodule WebCATWeb.AuthView do
  @moduledoc """
  View for rendering authentication responses
  """

  use WebCATWeb, :view

  def render("token.json", assigns) do
    Map.take(assigns, ~w(token)a)
  end
end
