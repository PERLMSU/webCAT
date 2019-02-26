defmodule WebCAT.Repo.Migrations.Accounts do
  use Ecto.Migration
  import WebCAT.Repo.Helpers
  import Terminator.Migrations

  def change do
    # Terminator
    performers()
    roles()
    performer_roles()
    abilities()
    entities()

    create table(:users) do
      add_req(:email, :text)
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add(:nickname, :text)
      add_req(:active, :boolean, default: true)

      add_req(:performer_id, references(Terminator.Performer.table()))

      timestamps()
    end

    create table(:password_credentials, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:password, :text)

      timestamps()
    end

    create table(:token_credentials, primary_key: false) do
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)
      add_req(:user_id, references(:users))

      timestamps()
    end

    create table(:password_resets, primary_key: false) do
      add_req(:user_id, references(:users))
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)

      timestamps()
    end

    create(unique_index(:users, ~w(email)a))
  end
end
