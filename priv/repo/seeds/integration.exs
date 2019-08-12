alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.{User, Notification, PasswordCredential}
alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}

alias WebCAT.Feedback.{
  Category,
  Observation,
  Feedback,
  Draft,
  Comment,
  Explanation,
  StudentFeedback,
  StudentExplanation
}

alias Terminator.{Role, Performer}

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true
  })

assistant_changeset =
  User.changeset(%User{}, %{
    first_name: "Assistant",
    last_name: "Account",
    email: "wcat_assistant@msu.edu",
    active: true
  })

classroom_changeset =
  Classroom.changeset(%Classroom{}, %{
    course_code: "PHY 183",
    name: "Physics for Scientists and Engineers I",
    description: "Default Classroom"
  })

transaction =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.run(:admin_role, fn repo, %{admin: user} ->
    Performer.grant(user.performer, repo.get_by!(Role, identifier: "admin"))

    {:ok, nil}
  end)
  |> Multi.insert(:assistant, assistant_changeset)
  |> Multi.run(:assistant_role, fn repo, %{assistant: user} ->
    Performer.grant(user.performer, repo.get_by!(Role, identifier: "assistant"))

    {:ok, nil}
  end)
  |> Multi.run(:admin_credentials, fn repo, %{admin: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      password: "password",
      user_id: user.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:assistant_credentials, fn repo, %{assistant: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      password: "password",
      user_id: user.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:classroom, fn repo, %{admin: admin} ->
    classroom_changeset
    |> Changeset.put_assoc(:users, [admin])
    |> repo.insert()
  end)
  |> Multi.run(:fall_semester, fn repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      name: "Fall",
      classroom_id: classroom.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:spring_semester, fn repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 10)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 19)),
      name: "Spring",
      classroom_id: classroom.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_section_1, fn repo, transaction ->
    %Section{}
    |> Section.changeset(%{
      number: "001",
      description:
        "Example section 001 for Fall Semester #{transaction.fall_semester.start_date.year}",
      semester_id: transaction.fall_semester.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_section_2, fn repo, transaction ->
    %Section{}
    |> Section.changeset(%{
      number: "002",
      description:
        "Example section 002 for Fall Semester #{transaction.fall_semester.start_date.year}",
      semester_id: transaction.fall_semester.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_rotation_1, fn repo, transaction ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 1,
      description:
        "Example rotation for #{transaction.fall_semester.name} semester section #{
          transaction.fall_section_1.number
        }",
      start_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 1)),
      end_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 2)),
      section_id: transaction.fall_section_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_rotation_2, fn repo, transaction ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 2,
      description:
        "Example rotation for #{transaction.fall_semester.name} semester section #{
          transaction.fall_section_1.number
        }",
      start_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 2)),
      end_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 3)),
      section_id: transaction.fall_section_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_student_1, fn repo, _transaction ->
    %User{}
    |> User.changeset(%{
      email: "john.doe@msu.edu",
      first_name: "John",
      last_name: "Doe"
    })
    |> repo.insert()
  end)
  |> Multi.run(:fall_student_2, fn repo, _transaction ->
    %User{}
    |> User.changeset(%{
      email: "jane.doe@msu.edu",
      first_name: "Jane",
      last_name: "Doe"
    })
    |> repo.insert()
  end)
  |> Multi.run(:student_roles, fn repo, transaction ->
    student_role = repo.get_by!(Role, identifier: "student")
    Performer.grant(transaction.fall_student_1.performer, student_role)
    Performer.grant(transaction.fall_student_2.performer, student_role)
    {:ok, nil}
  end)
  |> Multi.run(:rotation_group_1, fn repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 1",
      number: 1,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:users, [
      transaction.assistant,
      transaction.fall_student_1,
      transaction.fall_student_2
    ])
    |> repo.insert()
  end)
  |> Multi.run(:rotation_group_2, fn repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 2",
      number: 2,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:users, [transaction.assistant])
    |> repo.insert()
  end)
  |> Multi.run(:category_1, fn repo, transaction ->
    %Category{}
    |> Category.changeset(%{
      name: "Example Category",
      description: "Example Category for Example Classroom",
      classroom_id: transaction.classroom.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:observation_positive, fn repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example positive observation",
      category_id: transaction.category_1.id,
      type: "positive"
    })
    |> repo.insert()
  end)
  |> Multi.run(:observation_neutral, fn repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example neutral observation",
      category_id: transaction.category_1.id,
      type: "neutral"
    })
    |> repo.insert()
  end)
  |> Multi.run(:observation_negative, fn repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example negative observation",
      category_id: transaction.category_1.id,
      type: "negative"
    })
    |> repo.insert()
  end)
  |> Multi.run(:feedback_1, fn repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example feedback 1",
      observation_id: transaction.observation_positive.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:feedback_2, fn repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example feedback 2",
      observation_id: transaction.observation_positive.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:feedback_3, fn repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example feedback 3",
      observation_id: transaction.observation_neutral.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:explanation_1, fn repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 1",
      feedback_id: transaction.feedback_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:explanation_2, fn repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 2",
      feedback_id: transaction.feedback_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:explanation_3, fn repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 3",
      feedback_id: transaction.feedback_2.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:student_feedback_1, fn _repo, transaction ->
    StudentFeedback.add(
      transaction.rotation_group_1.id,
      transaction.fall_student_1.id,
      transaction.feedback_1.id
    )
  end)
  |> Multi.run(:student_feedback_2, fn _repo, transaction ->
    StudentFeedback.add(
      transaction.rotation_group_1.id,
      transaction.fall_student_1.id,
      transaction.feedback_2.id
    )
  end)
  |> Multi.run(:student_feedback_3, fn _repo, transaction ->
    StudentFeedback.add(
      transaction.rotation_group_1.id,
      transaction.fall_student_1.id,
      transaction.feedback_3.id
    )
  end)
   |> Multi.run(:student_explanation_1, fn _repo, transaction ->
    StudentExplanation.add(
      transaction.rotation_group_1.id,
      transaction.fall_student_1.id,
      transaction.feedback_1.id,
      transaction.explanation_2.id
    )
  end)
  |> Multi.run(:draft_1, fn repo, transaction ->
    %Draft{}
    |> Draft.changeset(%{
      content: "Example draft",
      status: "approved",
      reviewer_id: transaction.admin.id,
      student_id: transaction.fall_student_1.id,
      rotation_group_id: transaction.rotation_group_1.id
    })
    |> Changeset.put_assoc(:authors, [
      transaction.assistant
    ])
    |> repo.insert()
  end)
  |> Multi.run(:comment_1, fn repo, transaction ->
    %Comment{}
    |> Comment.changeset(%{
      content: "Looks good! Approving.",
      user_id: transaction.admin.id,
      draft_id: transaction.draft_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:comment_2, fn repo, transaction ->
    %Comment{}
    |> Comment.changeset(%{
      content: "Thanks! 👍",
      user_id: transaction.assistant.id,
      draft_id: transaction.draft_1.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:admin_notification, fn repo, transaction ->
    %Notification{}
    |> Notification.changeset(%{
      content: "There's a new draft for you to review!",
      draft_id: transaction.draft_1.id,
      user_id: transaction.admin.id
    })
    |> repo.insert()
  end)
  |> Multi.run(:assistant_notification, fn repo, transaction ->
    %Notification{}
    |> Notification.changeset(%{
      content: "Your draft has been approved!",
      draft_id: transaction.draft_1.id,
      user_id: transaction.assistant.id
    })
    |> repo.insert()
  end)

{:ok, _} = Repo.transaction(transaction)
