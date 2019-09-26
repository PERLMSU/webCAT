defmodule WebCAT.ImportTest do
  @moduledoc false
  use WebCAT.DataCase, async: true

  alias WebCAT.Import.Students
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Section

  describe "import/2" do
    test "behaves as expected" do
      section = Factory.insert(:section)
      path = Path.join(__DIR__, "../support/import.xlsx")
      :ok = Students.import(section.id, path)

      {:ok, after_import} = CRUD.get(Section, section.id, include: ~w(users)a)
      assert Enum.count(after_import.users) >= 4
    end
  end
end
