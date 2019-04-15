defmodule WebCATWeb.RotationView do
  use WebCATWeb, :dashboard_view

  alias WebCAT.Rotations.{Section, Sections}
  import Ecto.Changeset
end
