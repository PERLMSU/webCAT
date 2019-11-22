defmodule WebCATWeb.RotationGroupController do
  alias WebCATWeb.RotationGroupView
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  use WebCATWeb.ResourceController,
    schema: RotationGroup,
    view: RotationGroupView,
    type: "rotation_group",
    filter: ~w(number rotation_id),
    sort: ~w(number rotation_id inserted_at updated_at)
end
