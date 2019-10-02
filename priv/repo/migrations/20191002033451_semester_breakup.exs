defmodule WebCAT.Repo.Migrations.SemesterBreakup do
  use Ecto.Migration

  def change do
    alter table(:semesters) do
      remove(:classroom_id, references(:classrooms, on_delete: :delete_all), default: 1)
    end

    alter table(:sections) do
      add(:classroom_id, references(:classrooms, on_delete: :delete_all), null: false)
    end
  end
end
