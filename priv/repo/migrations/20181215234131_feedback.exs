defmodule WebCAT.Repo.Migrations.Feedback do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    enum("draft_status", ~w(unreviewed reviewing needs_revision approved emailed))
    enum("observation_type", ~w(positive neutral negative))

    create table(:categories) do
      add_req(:name, :text)
      add(:description, :text)
      add(:parent_category_id, references(:categories))
      add(:classroom_id, references(:classrooms))

      timestamps()
    end

    create table(:observations) do
      add_req(:content, :text)
      add_req(:type, :observation_type)
      add(:category_id, references(:categories))
      add(:rotation_group_id, references(:rotation_groups))

      timestamps()
    end

    create table(:explanations) do
      add_req(:content, :text)
      add_req(:observation_id, references(:observations))

      timestamps()
    end

    create table(:notes) do
      add_req(:content, :text)
      add(:student_id, references(:students))
      add(:observation_id, references(:observations))

      timestamps()
    end

    create table(:drafts) do
      add_req(:content, :text)
      add_req(:status, :draft_status)
      add_req(:student_id, :integer)
      add_req(:rotation_group_id, :integer)

      timestamps()
    end

    execute("""
    ALTER TABLE drafts ADD CONSTRAINT fk_draft_student_group FOREIGN KEY (student_id, rotation_group_id) REFERENCES student_groups (student_id, rotation_group_id);
    """,
    """
    ALTER TABLE drafts DROP CONSTRAINT fk_draft_student_group;
    """)

    create table(:draft_observations, primary_key: false) do
      add_req(:draft_id, references(:drafts), primary_key: true)
      add_req(:observation_id, references(:observations), primary_key: true)
    end

    create table(:emails) do
      add_req(:status, :text)
      add(:status_message, :text)
      add_req(:draft_id, references(:drafts))

      timestamps()
    end

    create table(:notifications) do
      add_req(:content, :text)
      add_req(:seen, :boolean, default: false)
      add_req(:draft_id, references(:drafts))
      add_req(:user_id, references(:users))

      timestamps()
    end

    create table(:criteria) do
      add_req(:min, :integer)
      add_req(:max, :integer)
      add_req(:title, :text)
      add_req(:description, :text)

      timestamps()
    end

    create table(:grades) do
      add_req(:score, :integer)
      add_req(:criteria_id, references(:criteria))
      add_req(:draft_id, references(:drafts))

      timestamps()
    end

    create(unique_index(:categories, ~w(name)a))
  end
end
