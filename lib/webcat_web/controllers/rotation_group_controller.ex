defmodule WebCATWeb.RotationGroupController do
  alias WebCATWeb.RotationGroupView
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  use WebCATWeb.ResourceController,
    schema: RotationGroup,
    view: RotationGroupView,
    type: "rotation_group",
    filter: ~w(number section_id),
    sort: ~w(number section_id start_date end_date inserted_at updated_at)
end
