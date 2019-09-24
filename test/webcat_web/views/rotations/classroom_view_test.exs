defmodule WebCATWeb.ClassroomViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.ClassroomView

  describe "render/2" do
    test "it renders a classroom properly", %{conn: conn} do
      classroom = Factory.insert(:classroom)
      rendered = ClassroomView.show(classroom, conn, %{})[:data]

      assert rendered[:id] == to_string(classroom.id)
      assert rendered[:attributes][:course_code] == classroom.course_code
      assert rendered[:attributes][:name] == classroom.name
      assert rendered[:attributes][:description] == classroom.description
    end

    test "it renders a list of classrooms properly", %{conn: conn} do
      classrooms = Factory.insert_list(3, :classroom)
      rendered_list = ClassroomView.index(classrooms, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
