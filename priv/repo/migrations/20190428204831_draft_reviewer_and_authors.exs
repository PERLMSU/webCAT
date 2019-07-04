defmodule WebCAT.Repo.Migrations.DraftReviewerAndAuthors do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def up do
    drop(constraint(:drafts, "fk_draft_user_group"))

    rename(table(:drafts), :user_id, to: :student_id)

    execute(
      ~s/ALTER TABLE drafts ADD CONSTRAINT drafts_student_group_fkey FOREIGN KEY (student_id, rotation_group_id) REFERENCES rotation_group_users (user_id, rotation_group_id) ON DELETE CASCADE;/
    )

    alter table(:drafts) do
      add(:reviewer_id, references(:users, on_delete: :nilify_all))
    end

    create table(:draft_authors, primary_key: false) do
      add_req(:draft_id, references(:drafts, on_delete: :delete_all), primary_key: true)
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
    end
  end

  def down do
    drop(constraint(:drafts, "drafts_student_group_fkey"))

    rename(table(:drafts), :student_id, to: :user_id)

    execute(
      ~s/ALTER TABLE drafts ADD CONSTRAINT fk_draft_user_group FOREIGN KEY (user_id, rotation_group_id) REFERENCES rotation_group_users (user_id, rotation_group_id) ON DELETE CASCADE;/
    )

    alter table(:drafts) do
      remove(:reviewer_id)
    end

    drop(table(:draft_authors))
  end
end
