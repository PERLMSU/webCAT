defmodule WebCAT.Factory do
  use ExMachina.Ecto, repo: WebCAT.Repo

  alias WebCAT.Accounts.{Notification, PasswordCredential, PasswordReset, TokenCredential, User}
  alias WebCAT.Feedback.{Category, Comment, Draft, Email, Feedback, Grade, Observation}
  alias WebCAT.Rotations.{Classroom, RotationGroup, Rotation, Semester, Section}
  alias WebCAT.Factory
  alias WebCAT.Repo
  alias Terminator.{Performer, Role}

  def notification_factory do
    %Notification{
      content: Enum.join(Faker.Lorem.sentences(2..3), "\n"),
      seen: false,
      draft: Factory.build(:draft),
      user: Factory.build(:user)
    }
  end

  def password_credential_factory do
    %PasswordCredential{
      password: Comeonin.Pbkdf2.hashpwsalt("password"),
      user: Factory.build(:user)
    }
  end

  def token_credential_factory do
    %TokenCredential{
      token: Base.encode32(:crypto.strong_rand_bytes(32)),
      expire: Timex.shift(Timex.now(), days: 1),
      user: Factory.build(:user)
    }
  end

  def password_reset_factory do
    %PasswordReset{
      token: Base.encode32(:crypto.strong_rand_bytes(32)),
      expire: Timex.shift(Timex.now(), days: 1),
      user: Factory.build(:user)
    }
  end

  def user_factory do
    performer = Factory.insert(:performer)

    %User{
      email: sequence(:email, &"email-#{&1}@msu.edu"),
      first_name: sequence(:first_name, ~w(John Jane)),
      last_name: "Doe",
      middle_name: sequence(:middle_name, ~w(James Renee)),
      nickname: sequence(:nickname, ~w(John Jane)),
      performer: performer,
      performer_id: performer.id,
      active: true
    }
  end

  def admin_factory do
    user = build(:user)
    role = Repo.get_by(Role, identifier: "admin")
    Performer.grant(user, role)
    user
  end

  def student_factory do
    user = build(:user)
    role = Repo.get_by(Role, identifier: "student")
    Performer.grant(user, role)
    user
  end

  def assistant_factory do
    user = build(:user)
    role = Repo.get_by(Role, identifier: "assistant")
    Performer.grant(user, role)
    user
  end

  def performer_factory do
    %Performer{}
  end

  def category_factory do
    classroom = Factory.build(:classroom)

    %Category{
      name: sequence(:name, &"category#{&1}"),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      classroom: classroom,
      sub_categories: Factory.build_list(3, :sub_category, classroom: classroom)
    }
  end

  def sub_category_factory do
    %Category{
      name: sequence(:name, &"sub_category#{&1}"),
      description: Enum.join(Faker.Lorem.sentences(), "\n")
    }
  end

  def comment_factory do
    %Comment{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      draft: Factory.build(:draft),
      user: Factory.build(:user)
    }
  end

  def draft_factory do
    student = Factory.insert(:student)
    rotation_group = Factory.insert(:rotation_group, users: [student])

    %Draft{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      status: sequence(:status, ~w(unreviewed reviewing needs_revision approved emailed)),
      user: student,
      rotation_group: rotation_group
    }
  end

  def email_factory do
    %Email{
      status: "delivered",
      draft: Factory.build(:draft)
    }
  end

  def feedback_factory do
    %Feedback{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      observation: Factory.build(:observation)
    }
  end

  def grade_factory do
    %Grade{
      score: Enum.random(0..100),
      note: Enum.join(Faker.Lorem.sentences(), "\n"),
      draft: Factory.build(:draft),
      category: Factory.build(:category)
    }
  end

  def observation_factory do
    %Observation{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      type: sequence(:type, ~w(positive neutral negative)),
      category: Enum.random(Factory.insert(:category).sub_categories)
    }
  end

  def classroom_factory do
    %Classroom{
      course_code: sequence(:course_code, &"PHY #{&1}"),
      name: sequence(:name, &"Physics for Scientists and Engineers #{&1}"),
      description: Enum.join(Faker.Lorem.sentences(), "\n")
    }
  end

  def rotation_group_factory do
    %RotationGroup{
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      number: sequence(:number, & &1),
      rotation: Factory.build(:rotation)
    }
  end

  def rotation_factory do
    %Rotation{
      number: sequence(:number, & &1),
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -1)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 2)),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      section: Factory.build(:section)
    }
  end

  def semester_factory do
    %Semester{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      classroom: Factory.build(:classroom),
      name: sequence(:name, ~w(Fall Spring))
    }
  end

  def section_factory do
    %Section{
      number: sequence(:number, &Integer.to_string/1),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      semester: Factory.build(:semester)
    }
  end
end
