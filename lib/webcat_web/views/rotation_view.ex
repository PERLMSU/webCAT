defmodule WebCATWeb.RotationView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Rotations.Rotation,
    item_name: "Rotation",
    collection_name: "Rotations"
end
