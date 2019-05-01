defmodule WebCATWeb.SemesterViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.SemesterView

  describe "render/2" do
    test "it renders a semester properly" do
      semester = Factory.insert(:semester)
      rendered = SemesterView.render("show.json", semester: semester)

      assert rendered[:id] == semester.id
      assert rendered[:name] == semester.name
      assert rendered[:description] == semester.description
      assert rendered[:classroom_id] == semester.classroom_id
    end

    test "it renders a list of semesters properly" do
      semesters = Factory.insert_list(3, :semester)
      rendered_list = SemesterView.render("list.json", semesters: semesters)
      assert Enum.count(rendered_list) == 3
    end
  end
end
