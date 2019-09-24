defmodule WebCATWeb.RotationViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.RotationView

  describe "render/2" do
    test "it renders a rotation properly", %{conn: conn} do
      rotation = Factory.insert(:rotation)
      rendered = RotationView.show(rotation, conn, %{})[:data]

      assert rendered[:id] == to_string(rotation.id)
      assert rendered[:attributes][:number] == rotation.number
      assert rendered[:attributes][:description] == rotation.description
      assert rendered[:attributes][:section_id] == rotation.section_id
    end

    test "it renders a list of rotations properly", %{conn: conn} do
      rotations = Factory.insert_list(3, :rotation)
      rendered_list = RotationView.index(rotations, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
