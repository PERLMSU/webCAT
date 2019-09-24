defmodule WebCATWeb.RotationGroupViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.RotationGroupView

  describe "render/2" do
    test "it renders a rotation group properly", %{conn: conn} do
      rotation_group = Factory.insert(:rotation_group)
      rendered = RotationGroupView.show(rotation_group, conn, %{})[:data]

      assert rendered[:id] == to_string(rotation_group.id)
      assert rendered[:attributes][:number] == rotation_group.number
      assert rendered[:attributes][:description] == rotation_group.description
      assert rendered[:attributes][:rotation_id] == rotation_group.rotation_id
    end

    test "it renders a list of rotation groups properly", %{conn: conn} do
      rotation_groups = Factory.insert_list(3, :rotation_group)
      rendered_list = RotationGroupView.index(rotation_groups, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
