defmodule WebCATWeb.ViewHelpersTest do
  @moduledoc false
  use WebCAT.DataCase, async: true

  alias WebCATWeb.ViewHelpers

  describe "timestamps_format/1" do
    test "datetimes are Unix time" do
      user = Factory.insert(:user)

      formatted = ViewHelpers.timestamps_format(Map.from_struct(user))

      assert is_integer(formatted[:inserted_at])
      assert is_integer(formatted[:updated_at])
      assert user.inserted_at == DateTime.from_unix!(formatted[:inserted_at])
      assert user.updated_at == DateTime.from_unix!(formatted[:updated_at])
    end
  end
end
