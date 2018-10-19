defmodule WebCATWeb.SemestersViewTest do
  use WebCAT.DataCase, async: true

  alias WebCATWeb.SemestersView

  test "clean_semester/1 behaves as expected" do
    semester = Factory.insert(:semester)

    cleaned = SemestersView.clean_semester(semester)

    assert is_binary(cleaned.start_date)
    assert is_binary(cleaned.end_date)
  end
end
