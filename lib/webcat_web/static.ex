defmodule WebCATWeb.MediaStatic do
  use Plug.Builder

  plug(Plug.Static, at: "/media", from: {:webcat, "priv/media"}, only: ~w(profiles), gzip: true)

  plug :default

  def default(conn, _) do
    if conn.request_path =~ ~r(/media/profiles/\d+) do
      send_file(conn, 200, Application.app_dir(:webcat, "priv/static/images/default_profile.png"))
    else
      conn
    end
  end
end
