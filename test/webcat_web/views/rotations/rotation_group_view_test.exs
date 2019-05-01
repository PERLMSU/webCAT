defmodule WebCATWeb.RotationGroupViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.RotationGroupView

  describe "render/2" do
    test "it renders a rotation group properly" do
      rotation_group = Factory.insert(:rotation_group)
      rendered = RotationGroupView.render("show.json", rotation_group: rotation_group)

      assert rendered[:id] == rotation_group.id
      assert rendered[:number] == rotation_group.number
      assert rendered[:description] == rotation_group.description
      assert rendered[:rotation_id] == rotation_group.rotation_id
    end

    test "it renders a list of rotation groups properly" do
      rotation_groups = Factory.insert_list(3, :rotation_group)
      rendered_list = RotationGroupView.render("list.json", rotation_groups: rotation_groups)
      assert Enum.count(rendered_list) == 3
    end
  end
end
