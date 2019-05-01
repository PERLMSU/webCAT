defmodule WebCATWeb.ClassroomViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.ClassroomView

  describe "render/2" do
    test "it renders a classroom properly" do
      classroom = Factory.insert(:classroom)
      rendered = ClassroomView.render("show.json", classroom: classroom)

      assert rendered[:id] == classroom.id
      assert rendered[:course_code] == classroom.course_code
      assert rendered[:name] == classroom.name
      assert rendered[:description] == classroom.description
    end

    test "it renders a list of classrooms properly" do
      classrooms = Factory.insert_list(3, :classroom)
      rendered_list = ClassroomView.render("list.json", classrooms: classrooms)
      assert Enum.count(rendered_list) == 3
    end
  end
end
