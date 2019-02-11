defmodule WebCAT.Repo.Migrations.Feedback do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    enum("draft_status", ~w(unreviewed reviewing needs_revision approved emailed))
    enum("observation_type", ~w(positive neutral negative))

    create table(:categories) do
      add_req(:name, :text)
      add(:description, :text)
      add(:parent_category_id, references(:categories, on_delete: :delete_all))
      add(:classroom_id, references(:classrooms, on_delete: :delete_all))

      timestamps()
    end

    create table(:observations) do
      add_req(:content, :text)
      add_req(:type, :observation_type)
      add(:category_id, references(:categories, on_delete: :delete_all))

      timestamps()
    end

    create table(:feedback) do
      add_req(:content, :text)
      add_req(:observation_id, references(:observations, on_delete: :delete_all))

      timestamps()
    end

    create table(:student_feedback, primary_key: false) do
      add_req(:feedback_id, references(:feedback, on_delete: :delete_all), primary_key: true)
      add_req(:rotation_group_id, :integer, primary_key: true)
      add_req(:student_id, :integer, primary_key: true)

      timestamps()
    end

    execute(
      """
      ALTER TABLE student_feedback ADD CONSTRAINT fk_feedback_student_group FOREIGN KEY (student_id, rotation_group_id) REFERENCES student_groups (student_id, rotation_group_id) ON DELETE CASCADE;
      """,
      """
      ALTER TABLE student_feedback DROP CONSTRAINT fk_feedback_student_group;
      """
    )

    create table(:drafts) do
      add_req(:content, :text)
      add_req(:status, :draft_status)
      add_req(:student_id, :integer)
      add_req(:rotation_group_id, :integer)

      timestamps()
    end

    execute(
      """
      ALTER TABLE drafts ADD CONSTRAINT fk_draft_student_group FOREIGN KEY (student_id, rotation_group_id) REFERENCES student_groups (student_id, rotation_group_id) ON DELETE CASCADE;
      """,
      """
      ALTER TABLE drafts DROP CONSTRAINT fk_draft_student_group;
      """
    )

    create table(:comments) do
      add_req(:content, :text)
      add(:draft_id, references(:drafts, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create table(:emails) do
      add_req(:status, :text)
      add_req(:draft_id, references(:drafts, on_delete: :delete_all))

      timestamps()
    end

    create table(:notifications) do
      add_req(:content, :text)
      add_req(:seen, :boolean, default: false)
      add_req(:draft_id, references(:drafts, on_delete: :delete_all))
      add_req(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create table(:grades) do
      add_req(:score, :integer)
      add(:note, :text)
      add_req(:category_id, references(:categories, on_delete: :delete_all))
      add_req(:draft_id, references(:drafts, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:categories, ~w(name)a))
  end
end
