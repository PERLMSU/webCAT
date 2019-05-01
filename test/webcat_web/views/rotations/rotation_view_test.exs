defmodule WebCATWeb.RotationViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.RotationView

  describe "render/2" do
    test "it renders a rotation properly" do
      rotation = Factory.insert(:rotation)
      rendered = RotationView.render("show.json", rotation: rotation)

      assert rendered[:id] == rotation.id
      assert rendered[:number] == rotation.number
      assert rendered[:description] == rotation.description
      assert rendered[:section_id] == rotation.section_id
    end

    test "it renders a list of rotations properly" do
      rotations = Factory.insert_list(3, :rotation)
      rendered_list = RotationView.render("list.json", rotations: rotations)
      assert Enum.count(rendered_list) == 3
    end
  end
end
