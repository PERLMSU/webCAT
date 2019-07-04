defmodule WebCAT.Repo.Migrations.AddExplanations do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    create table(:explanations) do
      add_req(:content, :text)
      add_req(:feedback_id, references(:feedback, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end
  end
end
