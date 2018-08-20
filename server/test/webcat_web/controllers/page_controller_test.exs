defmodule WebCATWeb.PageControllerTest do
  use WebCATWeb.ConnCase

  test "GET /", %{conn: conn} do
    get(conn, "/")
    |> html_response(200)
  end
end
