defmodule WebCATWeb.RotationController do

  alias WebCATWeb.RotationView
  alias WebCAT.Rotations.Rotation

  use WebCATWeb.ResourceController,
    schema: Rotation,
    view: RotationView,
    type: "rotation",
    filter: ~w(number section_id),
    sort: ~w(number section_id start_date end_date inserted_at updated_at)

end
