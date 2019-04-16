defmodule WebCATWeb.RotationView do
  use WebCATWeb, :dashboard_view

  alias WebCAT.Rotations.{Section, Sections, Semesters}
  import Ecto.Changeset
end
