defmodule WebCATWeb.ImportTest do
  use WebCAT.DataCase
  alias WebCATWeb.Import

  describe "from_path/1" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WebCAT.Repo)

    path = Path.join(__DIR__, "../support/import.xlsx")
  end
end
