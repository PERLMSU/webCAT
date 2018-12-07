defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb.Macros.Controller,
  schema: WebCAT.Rotations.RotationGroup,
  item_name: "Rotation Group",
  collection_name: "Rotation Groups"
end
