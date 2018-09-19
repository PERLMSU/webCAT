defmodule WebCATWeb.AuthView do
  @moduledoc """
  View for rendering authentication responses
  """

  use WebCATWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end
