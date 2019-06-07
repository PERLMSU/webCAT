defmodule WebCATWeb.UserView do
  use JSONAPI.View

  alias WebCATWeb.{ClassroomView, SemesterView, SectionView, RotationView, RotationGroupView}

  def fields, do: ~w(id first_name last_name email)a

  def type, do: "user"

  def relationships do
    [ classrooms: ClassroomView,
      semesters: SemesterView,
      sections: SectionView,
      rotations: RotationView,
      rotation_groups: RotationGroupView ]
  end
end
