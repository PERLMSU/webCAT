defmodule WebCATWeb.ErrorViewTest do
  use WebCATWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.json" do
    assert render(WebCATWeb.ErrorView, "400.json", %{message: "yeet"}) == %{
             errors: %{detail: "yeet"}
           }
  end

  test "renders 401.json" do
    assert render(WebCATWeb.ErrorView, "401.json", %{message: "yeet"}) == %{
             errors: %{detail: "unauthorized", message: "yeet"}
           }
  end

  test "renders 403.json" do
    assert render(WebCATWeb.ErrorView, "403.json", %{message: "yeet"}) == %{
             errors: %{detail: "forbidden", message: "yeet"}
           }
  end

  test "renders 404.json" do
    assert render(WebCATWeb.ErrorView, "404.json", %{message: "yeet"}) == %{
             errors: %{detail: "not found", message: "yeet"}
           }
  end

  test "render 500.json" do
    assert render(WebCATWeb.ErrorView, "500.json", %{message: "yeet"}) == %{
             errors: %{detail: "Internal server error", message: "Internal server error"}
           }
  end

  test "render any other" do
    assert render(WebCATWeb.ErrorView, "505.json", %{message: "yeet"}) == %{
             errors: %{detail: "Internal server error", message: "Internal server error"}
           }
  end
end
