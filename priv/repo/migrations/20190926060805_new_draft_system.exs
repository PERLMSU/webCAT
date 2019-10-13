defmodule WebCAT.Repo.Migrations.NewDraftSystem do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    alter table(:drafts) do
      add(:notes, :text)
      add(:parent_draft_id, references(:drafts))

      modify(:rotation_group_id, references(:rotation_groups), null: true)
      modify(:student_id, references(:users, on_delete: :nilify_all), null: true)

      # Remove reviewer in favor of just doing review requests
      remove(:reviewer_id, references(:users), default: nil)
    end

    drop(table(:draft_authors))

    create table(:review_request, primary_key: false) do
      add_req(:draft_id, references(:drafts, on_delete: :delete_all), primary_key: true)
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
    end

    # Student feedback and explanations are now tied to drafts
    drop(table(:student_explanations))
    drop(table(:student_feedback))

    create table(:student_feedback, primary_key: false) do
      add_req(:id, :bigserial)
      add_req(:draft_id, references(:drafts, on_delete: :delete_all), primary_key: true)
      add_req(:feedback_id, references(:feedback, on_delete: :delete_all), primary_key: true)

      timestamps(type: :timestamptz)
    end

    create table(:student_explanations, primary_key: false) do
      add_req(:id, :bigserial)
      add_req(:draft_id, :integer, primary_key: true)
      add_req(:feedback_id, :integer, primary_key: true)
      add_req(:explanation_id, references(:explanations, on_delete: :delete_all), primary_key: true)
      
      timestamps(type: :timestamptz)
    end

    alter table(:categories) do
      remove(:classroom_id, references(:classrooms), default: 1)
    end

    create table(:classroom_categories, primary_key: false) do
      add_req(:category_id, references(:categories, on_delete: :delete_all), primary_key: true)
      add_req(:classroom_id, references(:classrooms, on_delete: :delete_all), primary_key: true)
    end

    execute(
      """
      ALTER TABLE student_explanations ADD CONSTRAINT fk_student_feedback FOREIGN KEY (draft_id, feedback_id) REFERENCES student_feedback (draft_id, feedback_id) ON DELETE CASCADE;
      """,
      """
      ALTER TABLE student_explanations DROP CONSTRAINT fk_student_feedback;
      """
    )

    enum("role", ~w(admin faculty teaching_assistant learning_assistant student))

    alter table(:users) do
      remove(:performer_id, references(Terminator.Performer.table()), default: 1)

      add_req(:role, :role)
    end

    drop table(:terminator_performers_roles)
    drop table(:terminator_performers_entities)
    drop table(Terminator.Performer.table())
    drop table(:terminator_roles)
    drop table(:terminator_abilities)
  end
end
