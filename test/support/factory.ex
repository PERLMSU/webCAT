defmodule WebCAT.Factory do
  use ExMachina.Ecto, repo: WebCAT.Repo

  alias WebCAT.Accounts.{Notification, PasswordCredential, PasswordReset, TokenCredential, User}

  alias WebCAT.Feedback.{
    Category,
    Comment,
    Draft,
    Email,
    Feedback,
    Grade,
    Observation,
    Explanation,
    StudentFeedback,
    StudentExplanation
  }

  alias WebCAT.Rotations.{Classroom, RotationGroup, Rotation, Semester, Section}
  alias WebCAT.Factory
  alias WebCAT.Repo

  def notification_factory do
    %Notification{
      content: Enum.join(Faker.Lorem.sentences(2..3), "\n"),
      seen: false,
      draft: Factory.build(:student_draft),
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
    %User{
      email: sequence(:email, &"email-#{&1}@msu.edu"),
      first_name: sequence(:first_name, ~w(John Jane)),
      last_name: "Doe",
      middle_name: sequence(:middle_name, ~w(James Renee)),
      nickname: sequence(:nickname, ~w(John Jane)),
      active: true,
      role: "student"
    }
  end

  def student_factory do
    build(:user, role: "student")
  end

  def admin_factory do
    build(:user, role: "admin")
  end

  def assistant_factory do
    build(:user, role: "learning_assistant")
  end

  def category_factory do
    %Category{
      name: sequence("category"),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      sub_categories: Factory.build_list(1, :sub_category)
    }
  end

  def sub_category_factory do
    %Category{
      name: sequence("sub_category"),
      description: Enum.join(Faker.Lorem.sentences(), "\n")
    }
  end

  def comment_factory do
    %Comment{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      draft: Factory.build(:student_draft),
      user: Factory.build(:user)
    }
  end

  def group_draft_factory do
    rotation_group = Factory.build(:rotation_group)

    %Draft{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      notes: Enum.join(Faker.Lorem.sentences(), "\n"),
      status: sequence(:status, ~w(unreviewed reviewing needs_revision approved emailed)),
      rotation_group: rotation_group,
    }
  end

  def student_draft_factory do
    student = Factory.insert(:student)

    %Draft{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      notes: Enum.join(Faker.Lorem.sentences(), "\n"),
      status: sequence(:status, ~w(unreviewed reviewing needs_revision approved emailed)),
      student: student,
      parent_draft: Factory.insert(:group_draft)
    }
  end

  def email_factory do
    %Email{
      status: "delivered",
      draft: Factory.build(:student_draft)
    }
  end

  def feedback_factory do
    %Feedback{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      observation: Factory.build(:observation)
    }
  end

  def explanation_factory do
    %Explanation{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      feedback: Factory.build(:feedback)
    }
  end

  def grade_factory do
    %Grade{
      score: Enum.random(0..100),
      note: Enum.join(Faker.Lorem.sentences(), "\n"),
      draft: Factory.build(:student_draft),
      category: Factory.build(:category)
    }
  end

  def observation_factory do
    %Observation{
      content: Enum.join(Faker.Lorem.sentences(), "\n"),
      type: sequence(:type, ~w(positive neutral negative)),
      category: Enum.random(Factory.build(:category).sub_categories)
    }
  end

  def student_feedback_factory do
    %StudentFeedback{
      id: sequence(:sf_id, & &1),
      feedback: Factory.build(:feedback),
      draft: Factory.build(:student_draft)
    }
  end

  def student_explanation_factory do
    student_feedback = Factory.insert(:student_feedback)

    %StudentExplanation{
      id: sequence(:se_id, & &1),
      explanation: Factory.build(:explanation),
      feedback: student_feedback.feedback,
      draft: student_feedback.draft
    }
  end

  def classroom_factory do
    %Classroom{
      course_code: sequence("PHY "),
      name: sequence("Physics for Scientists and Engineers "),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      users: [Factory.insert(:admin)] ++ Factory.insert_list(1, :assistant),
      categories: Factory.insert_list(2, :category)
    }
  end

  def rotation_group_factory do
    %RotationGroup{
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      number: sequence(:number, & &1),
      rotation: Factory.build(:rotation),
      users: [Factory.insert(:assistant)] ++ Factory.insert_list(1, :student)
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
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      users: Factory.insert_list(1, :assistant),
      name: sequence(:name, ~w(Fall Spring))
    }
  end

  def section_factory do
    %Section{
      number: sequence(:number, &Integer.to_string/1),
      description: Enum.join(Faker.Lorem.sentences(), "\n"),
      semester: Factory.build(:semester),
      classroom: Factory.build(:classroom),
      users: [Factory.insert(:assistant)] ++ Factory.insert_list(1, :student)
    }
  end
end
