defmodule Release.Tasks do
  @doc """
  Tasks to run when a release first starts
  """
  def migrate do
    {:ok, _} = Application.ensure_all_started(:webcat)
    path = Application.app_dir(:webcat, "priv/repo/migrations")
    Ecto.Migrator.run(WebCAT.Repo, path, :up, all: true)
  end
end
