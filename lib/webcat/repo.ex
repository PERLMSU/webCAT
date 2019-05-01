defmodule WebCAT.Repo do
  use Ecto.Repo,
    otp_app: :webcat,
    adapter: Ecto.Adapters.Postgres
end
