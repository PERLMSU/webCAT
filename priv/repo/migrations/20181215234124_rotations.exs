defmodule WebCAT.Repo.Migrations.Rotations do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    create table(:classrooms) do
      add_req(:course_code, :text)
      add_req(:title, :text)
      add(:description, :text)

      timestamps()
    end

    create table(:semesters) do
      add_req(:title, :text)
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:classroom_id, references(:classrooms))

      timestamps()
    end

    create table(:sections) do
      add_req(:number, :text)
      add(:description, :text)
      add_req(:semester_id, references(:semesters))

      timestamps()
    end

    create table(:rotations) do
      add_req(:number, :integer)
      add(:description, :text)
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:section_id, references(:sections))

      timestamps()
    end

    create table(:rotation_groups) do
      add_req(:number, :integer)
      add(:description, :text)
      add_req(:rotation_id, references(:rotations))

      timestamps()
    end

    create table(:students) do
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add(:description, :text)
      add(:email, :text)

      timestamps()
    end

    create table(:user_classrooms, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:classroom_id, references(:classrooms), primary_key: true)
    end

    create table(:user_sections, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:section_id, references(:sections), primary_key: true)
    end

    create table(:rotation_group_users, primary_key: false) do
      add_req(:rotation_group_id, references(:rotation_groups), primary_key: true)
      add_req(:user_id, references(:users), primary_key: true)
    end

    create table(:student_groups, primary_key: false) do
      add_req(:rotation_group_id, references(:rotation_groups), primary_key: true)
      add_req(:student_id, references(:students), primary_key: true)
    end

    create table(:student_sections, primary_key: false) do
      add_req(:student_id, references(:students), primary_key: true)
      add_req(:section_id, references(:sections), primary_key: true)
    end

    create(unique_index(:students, ~w(email)a))
  end
end
