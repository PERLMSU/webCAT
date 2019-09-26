defmodule WebCATWeb.ObservationViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.ObservationView

  describe "render/2" do
    test "it renders an observation properly", %{conn: conn} do
      observation = Factory.insert(:observation)
      rendered = ObservationView.show(observation, conn, %{})[:data]

      assert rendered[:id] == to_string(observation.id)
      assert rendered[:attributes][:content] == observation.content
      assert rendered[:attributes][:category_id] == observation.category_id
    end

    test "it renders a list of observations properly", %{conn: conn} do
      observations = Factory.insert_list(3, :observation)
      rendered_list = ObservationView.index(observations, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
