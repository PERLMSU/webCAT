defmodule WebCATWeb.RotationController do
  use WebCATWeb.Macros.Controller,
  schema: WebCAT.Rotations.Rotation,
  item_name: "Rotation",
  collection_name: "Rotations"
end
