defmodule WebCATWeb.ErrorViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.ErrorView
  alias WebCAT.Rotations.Rotation

  describe "render/2" do
    test "400.json" do
      params = Factory.string_params_for(:rotation_group)
      changeset = Rotation.changeset(%Rotation{}, params)
      rendered = ErrorView.render("400.json", changeset: changeset)

      assert Enum.count(rendered[:errors][:section_id]) == 1

      rendered = ErrorView.render("400.json")
      assert rendered[:error][:status] == "400"
      assert rendered[:error][:title] == "Bad Request"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("400.json", message: "abc")
      assert rendered[:error][:status] == "400"
      assert rendered[:error][:title] == "Bad Request"
      assert rendered[:error][:message] == "abc"
    end

    test "401.json" do
      rendered = ErrorView.render("401.json")
      assert rendered[:error][:status] == "401"
      assert rendered[:error][:title] == "Unauthorized"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("401.json", message: "abc")
      assert rendered[:error][:status] == "401"
      assert rendered[:error][:title] == "Unauthorized"
      assert rendered[:error][:message] == "abc"
    end

    test "403.json" do
      rendered = ErrorView.render("403.json")
      assert rendered[:error][:status] == "403"
      assert rendered[:error][:title] == "Forbidden"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("403.json", message: "abc")
      assert rendered[:error][:status] == "403"
      assert rendered[:error][:title] == "Forbidden"
      assert rendered[:error][:message] == "abc"
    end

    test "404.json" do
      rendered = ErrorView.render("404.json")
      assert rendered[:error][:status] == "404"
      assert rendered[:error][:title] == "Not Found"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("404.json", message: "abc")
      assert rendered[:error][:status] == "404"
      assert rendered[:error][:title] == "Not Found"
      assert rendered[:error][:message] == "abc"
    end

    test "500.json" do
      rendered = ErrorView.render("500.json")
      assert rendered[:error][:status] == "500"
      assert rendered[:error][:title] == "Internal Server Error"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("500.json", message: "abc")
      assert rendered[:error][:status] == "500"
      assert rendered[:error][:title] == "Internal Server Error"
      assert rendered[:error][:message] == "abc"
    end

    test "catch-all" do
      rendered = ErrorView.render("abc")
      assert rendered[:error][:status] == "500"
      assert rendered[:error][:title] == "Internal Server Error"
      refute Map.has_key?(rendered[:error], :message)

      rendered = ErrorView.render("abc", message: "abc")
      assert rendered[:error][:status] == "500"
      assert rendered[:error][:title] == "Internal Server Error"
      assert rendered[:error][:message] == "abc"
    end
  end
end
