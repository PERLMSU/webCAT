defmodule WebCAT.Repo.Migrations.DraftReviewer do
  use Ecto.Migration

  def change do
    alter table(:drafts) do
      add(:reviewer_id, references(:users, on_delete: :nilify_all))
    end
  end
end
