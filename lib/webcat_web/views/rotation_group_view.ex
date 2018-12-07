defmodule WebCATWeb.RotationGroupView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Rotations.RotationGroup,
    item_name: "Rotation Group",
    collection_name: "Rotation Groups"
end
