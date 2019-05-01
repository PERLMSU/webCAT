defmodule WebCAT.Repo.Migrations.Rotations do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    create table(:classrooms) do
      add_req(:course_code, :text)
      add_req(:name, :text)
      add(:description, :text)

      timestamps(type: :timestamptz)
    end

    create table(:semesters) do
      add_req(:name, :text)
      add(:description, :text)
      add_req(:start_date, :date)
      add_req(:end_date, :date)

      add_req(:classroom_id, references(:classrooms, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    create table(:sections) do
      add_req(:number, :text)
      add(:description, :text)

      add_req(:semester_id, references(:semesters, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    create table(:rotations) do
      add_req(:number, :integer)
      add(:description, :text)
      add_req(:start_date, :date)
      add_req(:end_date, :date)

      add_req(:section_id, references(:sections, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    create table(:rotation_groups) do
      add_req(:number, :integer)
      add(:description, :text)

      add_req(:rotation_id, references(:rotations, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    # Join tables

    create table(:classroom_users, primary_key: false) do
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
      add_req(:classroom_id, references(:classrooms, on_delete: :delete_all), primary_key: true)
    end

    create table(:semester_users, primary_key: false) do
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
      add_req(:semester_id, references(:semesters, on_delete: :delete_all), primary_key: true)
    end

    create table(:section_users, primary_key: false) do
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
      add_req(:section_id, references(:sections, on_delete: :delete_all), primary_key: true)
    end

    create table(:rotation_users, primary_key: false) do
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
      add_req(:rotation_id, references(:rotations, on_delete: :delete_all), primary_key: true)
    end

    create table(:rotation_group_users, primary_key: false) do
      add_req(:rotation_group_id, references(:rotation_groups, on_delete: :delete_all),
        primary_key: true
      )

      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
    end

    create(unique_index(:classrooms, ~w(course_code)a))
  end
end
