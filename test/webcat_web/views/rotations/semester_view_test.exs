defmodule WebCATWeb.SemesterViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.SemesterView


  describe "render/2" do
    test "it renders a semester properly", %{conn: conn} do
      semester = Factory.insert(:semester)
      rendered = SemesterView.show(semester, conn, %{})
      data = rendered[:data]
      attributes = data[:attributes]

      assert data[:id] == to_string(semester.id)
      assert attributes[:name] == semester.name
      assert attributes[:description] == semester.description
      assert attributes[:start_date] == Timex.to_unix(semester.start_date)
      assert attributes[:end_date] == Timex.to_unix(semester.end_date)
      assert attributes[:classroom_id] == semester.classroom_id
      assert attributes[:inserted_at] == Timex.to_unix(semester.inserted_at)
      assert attributes[:updated_at] == Timex.to_unix(semester.updated_at)
    end

    test "it renders a list of semesters properly", %{conn: conn} do
      data = Factory.insert_list(3, :semester)
      rendered_list = SemesterView.index(data, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
