alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.User
alias WebCAT.Feedback.{Category, Observation, Explanation, Draft, Note}
alias WebCAT.Rotations.{Classroom, Semester, Rotation, RotationGroup, Student}

admin_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Admin",
    last_name: "McAdmin",
    email: "wcat_admin@msu.edu",
    username: "admin",
    password: "password",
    bio: "This is the default administrative account. Change its details as you please.",
    city: "East Lansing",
    state: "MI",
    country: "USA",
    active: true,
    role: "admin"
  })

instructor_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Ben",
    last_name: "Buscarino",
    username: "buscari3",
    email: "buscari3@msu.edu",
    password: "password",
    role: "instructor"
  })

semester_changeset =
  Semester.changeset(%Semester{}, %{
    start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
    end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
    title: "Fall Semester"
  })

category_changeset = Category.changeset(%Category{}, %{name: "Example", description: "Example Category"})

transaction =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.insert(:instructor, instructor_changeset)
  |> Multi.insert(:semester, semester_changeset)
  |> Multi.insert(:category, category_changeset)
  |> Multi.run(:classroom, fn _repo, %{semester: semester, instructor: instructor} ->
    Classroom.changeset(%Classroom{}, %{
      course_code: "PHY 183",
      section: "001",
      description: "Example Classroom",
      semester_id: semester.id
    })
    |> Changeset.put_assoc(:instructors, [instructor])
    |> Repo.insert()
  end)
  |> Multi.run(:rotation, fn _repo, %{classroom: classroom} ->
    {:ok, _} = Application.ensure_all_started(:timex)

    Rotation.changeset(%Rotation{}, %{
      start_date: Timex.to_date(Timex.now()),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 2)),
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:student1, fn _repo, %{classroom: classroom} ->
    %Student{}
    |> Student.changeset(%{
      first_name: "John",
      last_name: "Doe",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:student2, fn _repo, %{classroom: classroom} ->
    %Student{}
    |> Student.changeset(%{
      first_name: "Jane",
      last_name: "Doe",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:rotation_group, fn _repo, %{
                                     rotation: rotation,
                                     instructor: instructor,
                                     student1: student1,
                                     student2: student2
                                   } ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group",
      number: 1,
      rotation_id: rotation.id,
      instructor_id: instructor.id
    })
    |> Changeset.put_assoc(:students, [student1, student2])
    |> Repo.insert()
  end)
  |> Multi.run(:observation, fn _repo, %{rotation_group: rotation_group, category: category} ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Positive Content",
      type: "positive",
      category_id: category.id,
      rotation_group_id: rotation_group.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation, fn _repo, %{observation: observation} ->
    %Explanation{}
    |> Explanation.changeset(%{
      content: "Positive Explanation",
      observation_id: observation.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:note, fn _repo, %{observation: observation, student1: student} ->
    %Note{}
    |> Note.changeset(%{
      content: "Positive note for #{student.first_name} #{student.last_name}",
      observation_id: observation.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:draft, fn _repo, %{student1: student, rotation_group: rotation_group, observation: observation} ->
    %Draft{}
    |> Draft.changeset(%{
      content: "Positive Draft",
      status: "unreviewed",
      score: 1.00,
      student_id: student.id,
      rotation_group_id: rotation_group.id
    })
    |> Changeset.put_assoc(:observations, [observation])
    |> Repo.insert()
  end)


{:ok, _} = Repo.transaction(transaction)
