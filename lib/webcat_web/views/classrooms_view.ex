defmodule WebCATWeb.ClassroomsView do
  use WebCATWeb, :view

  def clean_classroom(classroom) do
    classroom
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
  end
end
