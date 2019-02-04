alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.User
alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup, Student}
alias WebCAT.Feedback.{Category, Observation, Explanation}

admin_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    username: "admin",
    password: "password",
    bio: "The default administrative account.",
    city: "East Lansing",
    state: "MI",
    country: "USA",
    active: true,
    role: "admin"
  })

assistant_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Assistant",
    last_name: "Account",
    email: "wcat_assistant@msu.edu",
    username: "assistant",
    password: "password",
    bio: "The default assistant account, here for example purposes and can be deleted.",
    city: "East Lansing",
    state: "MI",
    country: "USA",
    active: true,
    role: "assistant"
  })

classroom_changeset =
  Classroom.changeset(%Classroom{}, %{
    course_code: "PHY 183",
    title: "Physics for Scientists and Engineers I",
    description: "Default Classroom"
  })

transaction =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.insert(:assistant, assistant_changeset)
  |> Multi.run(:classroom, fn _repo, %{admin: admin} ->
    classroom_changeset
    |> Changeset.put_assoc(:users, [admin])
    |> Repo.insert()
  end)
  |> Multi.run(:fall_semester, fn _repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      title: "Fall",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:spring_semester, fn _repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 10)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 19)),
      title: "Spring",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_section_1, fn _repo,
                                   %{
                                     fall_semester: semester,
                                     assistant: assistant
                                   } ->
    %Section{}
    |> Section.changeset(%{
      number: "001",
      description: "Example section 001 for Fall Semester #{semester.start_date.year}",
      semester_id: semester.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_section_2, fn _repo,
                                   %{
                                     fall_semester: semester,
                                     assistant: assistant
                                   } ->
    %Section{}
    |> Section.changeset(%{
      number: "002",
      description: "Example section 002 for Fall Semester #{semester.start_date.year}",
      semester_id: semester.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_rotation_1, fn _repo, %{fall_section_1: section, fall_semester: semester} ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 1,
      description: "Example rotation for #{semester.title} semester section #{section.number}",
      start_date: Timex.to_date(Timex.shift(semester.start_date, weeks: 1)),
      end_date: Timex.to_date(Timex.shift(semester.start_date, weeks: 2)),
      section_id: section.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_rotation_2, fn _repo, %{fall_section_1: section, fall_semester: semester} ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 2,
      description: "Example rotation for #{semester.title} semester section #{section.number}",
      start_date: Timex.to_date(Timex.shift(semester.start_date, weeks: 2)),
      end_date: Timex.to_date(Timex.shift(semester.start_date, weeks: 3)),
      section_id: section.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_1, fn _repo, %{fall_section_1: section, fall_semester: semester} ->
    %Student{}
    |> Student.changeset(%{
      first_name: "John",
      last_name: "Doe",
      description: "Example student for #{semester.title} semester section #{section.number}",
      email: "john.doe@msu.edu"
    })
    |> Changeset.put_assoc(:sections, [section])
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_2, fn _repo, %{fall_section_1: section, fall_semester: semester} ->
    %Student{}
    |> Student.changeset(%{
      first_name: "Jane",
      last_name: "Doe",
      description: "Example student for #{semester.title} semester section #{section.number}",
      email: "jane.doe@msu.edu"
    })
    |> Changeset.put_assoc(:sections, [section])
    |> Repo.insert()
  end)
  |> Multi.run(:rotation_group_1, fn _repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 1",
      number: 1,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:students, [transaction.fall_student_1, transaction.fall_student_2])
    |> Changeset.put_assoc(:users, [transaction.assistant])
    |> Repo.insert()
  end)
  |> Multi.run(:rotation_group_2, fn _repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 2",
      number: 2,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:users, [transaction.assistant])
    |> Repo.insert()
  end)
  |> Multi.run(:category_1, fn _repo, transaction ->
    %Category{}
    |> Category.changeset(%{
      name: "Example Category",
      description: "Example Category for Example Classroom",
      classroom_id: transaction.classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_positive, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example positive observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "positive"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_neutral, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example neutral observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "neutral"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_negative, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example negative observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "negative"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_1, fn _repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 1",
      observation_id: transaction.observation_positive.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_2, fn _repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 2",
      observation_id: transaction.observation_positive.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_3, fn _repo, transaction ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Example explanation 3",
      observation_id: transaction.observation_neutral.id
    })
    |> Repo.insert()
  end)

{:ok, _} = Repo.transaction(transaction)
