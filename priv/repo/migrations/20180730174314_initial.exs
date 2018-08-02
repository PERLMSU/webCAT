defmodule WebCAT.Repo.Migrations.Initial do
  use Ecto.Migration

  defmacrop add_req(name, type, options \\ []) do
    # Macro for adding a required (not null) field to the schema
    quote do
      add(unquote(name), unquote(type), unquote(Keyword.put(options, :null, false)))
    end
  end

  def change do
    execute("CREATE EXTENSION pgcrypto;", "DROP EXTENSION pgcrypto;")
    execute("CREATE TYPE user_role AS ENUM ('instructor', 'admin');", "DROP TYPE IF EXISTS user_role;")
    execute("CREATE TYPE draft_status AS ENUM ('review', 'needs_revision', 'approved', 'emailed');", "DROP TYPE IF EXISTS draft_status;")

    # Accounts

    create table(:users) do
      add_req(:first_name, :string)
      add_req(:last_name, :string)
      add(:middle_name, :string)
      add_req(:email, :string)
      add_req(:username, :string)
      add_req(:password, :string)
      add(:nickname, :string)
      add(:bio, :string)
      add(:phone, :string)
      add(:city, :string)
      add(:state, :string)
      add(:country, :string)
      add(:birthday, :date)
      add_req(:active, :boolean, default: true)
      add_req(:role, :user_role, default: "instructor")

      timestamps()
    end

    create table(:confirmations) do
      add_req(:token, :string, default: fragment("gen_random_uuid()"))
      add_req(:user_id, references(:users))
      add_req(:verified, :boolean, default: false)

      timestamps()
    end

    create table(:password_resets) do
      add_req(:token, :string, default: fragment("gen_random_uuid()"))
      add_req(:user_id, references(:users))

      timestamps()
    end

    # Rotations

    create table(:semesters) do
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:title, :string)

      timestamps()
    end

    create table(:classrooms) do
      add_req(:course_code, :string)
      add_req(:course_number, :string)
      add(:description, :string)
      add(:section, :string)
      add_req(:semester_id, references(:semesters))

      timestamps()
    end

    create table(:user_classrooms, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:classroom_id, references(:classrooms), primary_key: true)

      timestamps()
    end

    create table(:rotations) do
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:classroom_id, references(:classrooms))

      timestamps()
    end

    create table(:students) do
      add_req(:first_name, :string)
      add_req(:last_name, :string)
      add(:middle_name, :string)
      add(:notes, :string)
      add(:email, :string)

      timestamps()
    end

    create table(:rotation_groups) do
      add(:description, :string)
      add_req(:number, :integer)
      add_req(:classroom_id, references(:classrooms))
      add_req(:instructor_id, references(:users))

      timestamps()
    end

    create table(:student_groups, primary_key: false) do
      add_req(:rotation_group_id, references(:rotation_groups), primary_key: true)
      add_req(:student_id, references(:students), primary_key: true)

      timestamps()
    end

    # Feedback

    create table(:categories) do
      add_req(:name, :string)
      add(:description, :string)
      add(:parent_category_id, references(:categories))

      timestamps()
    end

    create table(:observations) do
      add_req(:content, :string)
      add_req(:type, :string)
      add(:category_id, references(:categories))
      add(:rotation_group_id, references(:rotation_groups))

      timestamps()
    end

    create table(:feedback) do
      add_req(:content, :string)
      add_req(:observation_id, references(:observations))

      timestamps()
    end

    create table(:explanations) do
      add_req(:content, :string)
      add_req(:feedback_id, references(:feedback))

      timestamps()
    end

    create table(:notes) do
      add_req(:content, :string)
      add(:student_id, references(:students))
      add(:observation_id, references(:observations))
      add(:rotation_group_id, references(:observations))

      timestamps()
    end

    create table(:drafts) do
      add_req(:content, :string)
      add_req(:status, :draft_status)
      add_req(:instructor_id, references(:users))
      add_req(:student_id, references(:students))
      add_req(:rotation_group_id, references(:rotation_groups))

      timestamps()
    end

    create table(:emails) do
      add_req(:status, :string)
      add(:status_message, :string)
      add_req(:draft_id, references(:drafts))

      timestamps()
    end

    create table(:grades) do
      add_req(:score, :float)
      add_req(:draft_id, references(:drafts))

      timestamps()
    end

    create table(:notifications) do
      add_req(:content, :string)
      add_req(:seen, :boolean, default: false)
      add_req(:draft_id, references(:drafts))
      add_req(:user_id, references(:users))

      timestamps()
    end

    create(unique_index(:users, ~w(email username)a))
    create(unique_index(:confirmations, ~w(token)a))
    create(unique_index(:password_resets, ~w(token)a))
    create(unique_index(:categories, ~w(name)a))
    create(unique_index(:students, ~w(email)a))
  end
end
