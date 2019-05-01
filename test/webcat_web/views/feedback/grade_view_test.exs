defmodule WebCATWeb.GradeiewTest do
  use WebCAT.DataCase

  alias WebCATWeb.GradeView

  describe "render/2" do
    test "it renders a grade properly" do
      grade = Factory.insert(:grade)
      rendered = GradeView.render("show.json", grade: grade)

      assert rendered[:id] == grade.id
      assert rendered[:score] == grade.score
      assert rendered[:note] == grade.note
      assert rendered[:draft_id] == grade.draft_id
      assert rendered[:category_id] == grade.category_id
    end

    test "it renders a list of grades properly" do
      grades = Factory.insert_list(3, :grade)
      rendered_list = GradeView.render("list.json", grades: grades)
      assert Enum.count(rendered_list) == 3
    end
  end
end
