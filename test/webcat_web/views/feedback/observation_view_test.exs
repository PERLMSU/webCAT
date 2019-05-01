defmodule WebCATWeb.ObservationViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.ObservationView

  describe "render/2" do
    test "it renders an observation properly" do
      observation = Factory.insert(:observation)
      rendered = ObservationView.render("show.json", observation: observation)

      assert rendered[:id] == observation.id
      assert rendered[:content] == observation.content
      assert rendered[:category_id] == observation.category_id
    end

    test "it renders a list of observations properly" do
      observations = Factory.insert_list(3, :observation)
      rendered_list = ObservationView.render("list.json", observations: observations)
      assert Enum.count(rendered_list) == 3
    end
  end
end
