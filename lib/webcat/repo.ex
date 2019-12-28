defmodule WebCAT.Repo do
  use Ecto.Repo,
    otp_app: :webcat,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    loaded_config =
      config
      |> load_env(:url, "PG_URL")
      |> load_env(:socket_dir, "PG_SOCKET_DIR")
      |> load_env(:password, "PG_PASSWORD")
      |> load_env(:username, "PG_USERNAME")
      |> load_env(:host, "PG_HOST")
      |> load_env(:port, "PG_PORT")
      |> load_env(:database, "PG_DATABASE")

    {:ok, loaded_config}
  end

  defp load_env(config, key, name) do
    if Keyword.has_key?(config, key) do
      config
    else
      Keyword.put(config, key, System.get_env(name))
    end
  end
end
