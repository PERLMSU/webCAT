alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.User
alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup, Student}

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

instructor_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Instructor",
    last_name: "Account",
    email: "wcat_instructor@msu.edu",
    username: "instructor",
    password: "password",
    bio: "The default instructor account, here for example purposes and can be deleted.",
    city: "East Lansing",
    state: "MI",
    country: "USA",
    active: true,
    role: "instructor"
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
  |> Multi.insert(:instructor, instructor_changeset)
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
                                     instructor: instructor,
                                     assistant: assistant
                                   } ->
    %Section{}
    |> Section.changeset(%{
      number: "001",
      description: "Example section 001 for Fall Semester #{semester.start_date.year}",
      semester_id: semester.id
    })
    |> Changeset.put_assoc(:users, [instructor, assistant])
    |> Repo.insert()
  end)
  |> Multi.run(:fall_section_2, fn _repo,
                                   %{
                                     fall_semester: semester,
                                     instructor: instructor,
                                     assistant: assistant
                                   } ->
    %Section{}
    |> Section.changeset(%{
      number: "002",
      description: "Example section 002 for Fall Semester #{semester.start_date.year}",
      semester_id: semester.id
    })
    |> Changeset.put_assoc(:users, [instructor, assistant])
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


{:ok, _} = Repo.transaction(transaction)
