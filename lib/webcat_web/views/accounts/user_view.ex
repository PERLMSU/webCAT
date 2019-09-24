defmodule WebCATWeb.UserView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "user"

  alias WebCAT.Accounts.User

  alias WebCATWeb.{
    ClassroomView,
    SemesterView,
    SectionView,
    RotationView,
    RotationGroupView,
    RoleView
  }

  def fields, do: ~w(email first_name last_name middle_name nickname active inserted_at updated_at)a

  def relationships, do: [classrooms: ClassroomView, semesters: SemesterView, sections: SectionView, rotations: RotationView, rotation_groups: RotationGroupView]
end
