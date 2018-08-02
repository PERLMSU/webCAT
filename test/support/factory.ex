defmodule WebCAT.Factory do
  use ExMachina.Ecto, repo: WebCAT.Repo

  alias WebCAT.Accounts.{User, PasswordReset, Confirmation, Notification}
  alias WebCAT.Feedback.{Category, Draft, Email, Explanation, Feedback, Grade, Note, Observation}
  alias WebCAT.Rotations.{Classroom, RotationGroup, Rotation, Semester, Student}
  alias WebCAT.Factory

  def user_factory do
    %User{
      first_name: sequence(:first_name, ~w(John Jane)),
      last_name: "Doe",
      middle_name: sequence(:middle_name, ~w(James Renee)),
      email: sequence(:email, &"email-#{&1}@msu.edu"),
      username: sequence(:username, &"user#{&1}"),
      password: Comeonin.Pbkdf2.hashpwsalt("password"),
      nickname: sequence(:nickname, ~w(John Jane)),
      bio: Elixilorem.sentence(),
      phone: "989-992-9183",
      city: "East Lansing",
      state: "MI",
      country: "USA",
      birthday: Timex.to_date(Timex.shift(Timex.now(), years: -18)),
      active: true,
      role: sequence(:role, ~w(instructor admin)),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now(),
    }
  end

  def password_reset_factory do
    %PasswordReset{
      user: Factory.build(:user),
      token: PasswordReset.gen_token()
    }
  end

  def confirmation_factory do
    %Confirmation{
      user: Factory.build(:user),
      token: Confirmation.gen_token()
    }
  end

  def notification_factory do
    %Notification{
      content: Elixilorem.sentences(2),
      seen: false,
      draft: Factory.build(:draft),
      user: Factory.build(:user)
    }
  end

  def category_factory do
    %Category{
      name: sequence(:name, &"category#{&1}"),
      description: Elixilorem.sentence()
    }
  end

  def draft_factory do
    %Draft{
      content: Elixilorem.sentence(),
      status: sequence(:status, ~w(review needs_revision approved emailed)),
      instructor: Factory.build(:user),
      student: Factory.build(:student),
      rotation_group: Factory.build(:rotation_group)
    }
  end

  def email_factory do
    %Email{
      status: "delivered",
      status_message: "message delivered successfully",
      draft: Factory.build(:draft)
    }
  end

  def explanation_factory do
    %Explanation{
      content: Elixilorem.sentence(),
      feedback: Factory.build(:feedback)
    }
  end

  def feedback_factory do
    %Feedback{
      content: Elixilorem.sentence(),
      observation: Factory.build(:observation)
    }
  end

  def grade_factory do
    %Grade{
      # Random number up to 5, rounded to two decimal places
      score: Float.round(:rand.uniform() * 5, 2),
      draft: Factory.build(:draft)
    }
  end

  def misc_note_factory do
    %Note{
      content: Elixilorem.sentence()
    }
  end

  def student_note_factory do
    %Note{
      content: Elixilorem.sentence(),
      student: Factory.build(:student)
    }
  end

  def observation_note_factory do
    %Note{
      content: Elixilorem.sentence(),
      observation: Factory.build(:observation)
    }
  end

  def rotation_group_note_factory do
    %Note{
      content: Elixilorem.sentence(),
      rotation_group: Factory.build(:rotation_group)
    }
  end

  def observation_factory do
    %Observation{
      content: Elixilorem.sentence(),
      type: "positive",
      category: Factory.build(:category),
      rotation_group: Factory.build(:rotation_group)
    }
  end

  def classroom_factory do
    %Classroom{
      course_code: "PHY183",
      section: sequence(:section, &Integer.to_string/1),
      description: Elixilorem.sentence(),
      semester: Factory.build(:semester)
    }
  end

  def rotation_group_factory do
    %RotationGroup{
      description: Elixilorem.sentence(),
      number: sequence(:number, & &1),
      rotation: Factory.build(:rotation),
      instructor: Factory.build(:user, role: "learning_assistant")
    }
  end

  def rotation_factory do
    %Rotation{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -1)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 2)),
      classroom: Factory.build(:classroom)
    }
  end

  def semester_factory do
    %Semester{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      title: "Fall"
    }
  end

  def student_factory do
    %Student{
      first_name: sequence(:first_name, ~w(John Jane)),
      last_name: "Doe",
      middle_name: sequence(:middle_name, ~w(James Renee)),
      description: Elixilorem.sentences(2),
      email: sequence(:email, &"email-#{&1}@msu.edu"),
      classroom: Factory.build(:classroom)
    }
  end
end
