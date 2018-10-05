defmodule WebCAT.Repo.Migrations.InitialUser do
  use Ecto.Migration

  alias WebCAT.Repo
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.Semester

  def change do
    Repo.insert!(User.create_changeset(%User{}, %{
      first_name: "Admin",
      last_name: "McAdmin",
      email: "wcat_admin@msu.edu",
      username: "admin",
      password: "password",
      bio: "This is the default administrative account. Change it's details as you please.",
      city: "East Lansing",
      state: "MI",
      country: "USA",
      active: true,
      role: "admin",
    }))

    Application.ensure_all_started(:timex)

    Repo.insert!(Semester.changeset(%Semester{}, %{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      title: "Fall Semester"
    }))
  end
end
