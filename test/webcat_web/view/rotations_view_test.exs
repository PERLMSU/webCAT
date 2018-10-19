defmodule WebCATWeb.RotationsViewTest do
  use WebCAT.DataCase, async: true

  alias WebCATWeb.RotationsView

  test "clean_rotation/1 behaves as expected" do
    rotation = Factory.insert(:rotation)

    cleaned = RotationsView.clean_rotation(rotation)

    assert is_binary(cleaned.start_date)
    assert is_binary(cleaned.end_date)
  end
end
