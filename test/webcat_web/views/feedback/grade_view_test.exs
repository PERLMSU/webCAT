defmodule WebCATWeb.GradeViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.GradeView

  describe "render/2" do
    test "it renders a grade properly", %{conn: conn} do
      grade = Factory.insert(:grade)
      rendered = GradeView.show(grade, conn, %{})[:data]

      assert rendered[:id] == to_string(grade.id)
      assert rendered[:attributes][:score] == grade.score
      assert rendered[:attributes][:note] == grade.note
      assert rendered[:attributes][:draft_id] == grade.draft_id
      assert rendered[:attributes][:category_id] == grade.category_id
    end

    test "it renders a list of grades properly", %{conn: conn} do
      grades = Factory.insert_list(3, :grade)
      rendered_list = GradeView.index(grades, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
