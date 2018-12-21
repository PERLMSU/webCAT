defmodule WebCATWeb.Dashboard do
  use WebCATWeb.Macros.Dashboard

  resource WebCAT.Accounts.User do
    options(item_name: "user", collection_name: "Users")

    display(user) do
      user
      |> Map.from_struct()
      |> Map.take(~w(first_name last_name username)a)
    end

    # Which fields to include in the table view
    table_fields(~w(username first_name last_name)a)
    display_fields(~w(first_name last_name username)a)

    # For generating a title
    title(user) do
      "#{user.first_name} #{user.last_name}"
    end
  end

  resource WebCAT.Rotations.Classroom do
    options(item_name: "classroom", collection_name: "Classrooms")

    display(classroom) do
      classroom
      |> Map.from_struct()
      |> Map.take(~w(course_code title description)a)
    end

    title(classroom) do
      "#{classroom.course_code} - #{classroom.title}"
    end

    table_fields(~w(course_code title description)a)
    display_fields(~w(course_code title description)a)
  end

  resource WebCAT.Rotations.Semester do
    options(item_name: "semester", collection_name: "Semesters")

    display(semester) do
      semester
      |> Map.from_struct()
      |> Map.take(~w(title start_date end_date)a)
      |> Map.update!(:start_date, fn value ->
        if Timex.is_valid?(value) do
          "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
            Timex.format!(value, "{relative}", :relative)
          })"
        end
      end)
      |> Map.update!(:end_date, fn value ->
        if Timex.is_valid?(value) do
          "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
            Timex.format!(value, "{relative}", :relative)
          })"
        end
      end)
    end

    title(semester) do
      semester.title
    end

    table_fields(~w(title start_date end_date)a)
    display_fields(~w(title start_date end_date)a)
  end

  resource WebCAT.Rotations.Section do
    options(item_name: "section", collection_name: "Sections")

    display(section) do
      section
      |> Map.from_struct()
      |> Map.take(~w(number description)a)
    end

    title(section) do
      section.number
    end

    table_fields(~w(number description)a)
    display_fields(~w(number description)a)
  end

  resource WebCAT.Rotations.Rotation do
    options(item_name: "rotation", collection_name: "Rotations")

    display(rotation) do
      rotation
      |> Map.from_struct()
      |> Map.take(~w(start_date end_date)a)
      |> Map.update!(:start_date, fn value ->
        if Timex.is_valid?(value) do
          "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
            Timex.format!(value, "{relative}", :relative)
          })"
        end
      end)
      |> Map.update!(:end_date, fn value ->
        if Timex.is_valid?(value) do
          "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
            Timex.format!(value, "{relative}", :relative)
          })"
        end
      end)
    end

    title(rotation) do
      "Rotation #{Timex.format!(rotation.start_date, "{M} {D}, {YYYY}")} - #{
        Timex.format!(rotation.end_date, "{M} {D}, {YYYY}")
      }"
    end

    table_fields(~w(start_date end_date)a)
    display_fields(~w(start_date end_date)a)
  end

  resource WebCAT.Rotations.RotationGroup do
    options(item_name: "rotation_group", collection_name: "Rotation Groups")

    display(rotation_group) do
      rotation_group
      |> Map.from_struct()
      |> Map.take(~w(description number)a)
    end

    title(rotation_group) do
      "Group #{rotation_group.number}"
    end

    table_fields(~w(number description)a)
    display_fields(~w(number description)a)
  end

  resource WebCAT.Feedback.Category do
    options(item_name: "category", collection_name: "Categories")

    display(category) do
      category
      |> Map.from_struct()
      |> Map.take(~w(name description)a)
    end

    title(category) do
      category.name
    end

    table_fields(~w(name description)a)
    display_fields(~w(name description)a)
  end

  resource WebCAT.Rotations.Student do
    options(item_name: "student", collection_name: "Students")

    display(student) do
      student
      |> Map.from_struct()
      |> Map.take(~w(first_name last_name middle_name description email)a)
    end

    title(student) do
      "#{student.first_name} #{student.last_name}"
    end

    table_fields(~w(last_name first_name email description)a)
    display_fields(~w(last_name first_name email description)a)
  end
end
