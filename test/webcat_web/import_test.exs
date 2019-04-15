defmodule WebCATWeb.ImportTest do
  use WebCAT.DataCase
  alias WebCATWeb.Import

  describe "from_path/1" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WebCAT.Repo)

    path = Path.join(__DIR__, "../support/import.xlsx")
    {:ok, data} = Import.from_path(path)

    classroom = Map.fetch!(data, {:classroom, "1"})
    assert classroom.course_code == "PHY 183"
    assert classroom.name == "Physics for Scientists and Engineers I"
    assert classroom.description == "Default Classroom"

    spring = Map.fetch!(data, {:semester, "1"})
    assert spring.name == "Spring Semester"
    assert spring.description == "Test semester"
    assert spring.classroom_id == classroom.id
    fall = Map.fetch!(data, {:semester, "2"})
    assert fall.name == "Fall Semester"
    assert fall.description == "Test semester"
    assert fall.classroom_id == classroom.id

    section = Map.fetch!(data, {:section, "1"})
    assert section.number == "1"
    assert section.description == "Test section"
    assert section.semester_id == spring.id

    rotation = Map.fetch!(data, {:rotation, "1"})
    assert rotation.number == 1
    assert rotation.description == "Test rotation"
    assert rotation.section_id == section.id

    rotation_group = Map.fetch!(data, {:rotation_group, "1"})
    assert rotation_group.number == 1
    assert rotation_group.description == "Test rotation group"
    assert rotation_group.rotation_id == rotation.id

    student = Map.fetch!(data, {:student, "1"})
    assert student.email == "test@test.com"
    assert student.first_name == "John"
    assert student.last_name == "Doe"
    assert student.middle_name == "James"
    assert student.nickname == "Jim"

    category = Map.fetch!(data, {:category, "1"})
    assert category.name == "Test"
    assert category.description == "Test category"
    assert category.classroom_id == classroom.id
    assert category.parent_category_id == nil
    sub_category = Map.fetch!(data, {:category, "2"})
    assert sub_category.name == "Sub Category"
    assert sub_category.description == "Test sub-category"
    assert sub_category.classroom_id == classroom.id
    assert sub_category.parent_category_id == category.id

    pos_obs = Map.fetch!(data, {:observation, "1"})
    assert pos_obs.content == "Test positive observation"
    assert pos_obs.type == "positive"
    assert pos_obs.category_id == sub_category.id
    neut_obs = Map.fetch!(data, {:observation, "2"})
    assert neut_obs.content == "Test neutral observation"
    assert neut_obs.type == "neutral"
    assert neut_obs.category_id == sub_category.id
    neg_obs = Map.fetch!(data, {:observation, "3"})
    assert neg_obs.content == "Test negative observation"
    assert neg_obs.type == "negative"
    assert neg_obs.category_id == sub_category.id

    feedback = Map.fetch!(data, {:feedback, "1"})
    assert feedback.content == "Test feedback"
    assert feedback.observation_id == pos_obs.id
  end
end
