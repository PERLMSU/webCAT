defmodule WebCATWeb.RotationView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{Rotation, Section}

  def render("list.json", %{rotations: rotations}) do
    render_many(rotations, __MODULE__, "rotation.json")
  end

  def render("show.json", %{rotation: rotation}) do
    render_one(rotation, __MODULE__, "rotation.json")
  end

  def render("rotation.json", %{rotation: %Rotation{} = rotation}) do
    rotation
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> Map.update!(:start_date, &Timex.to_unix/1)
    |> Map.update!(:end_date, &Timex.format!(&1, "{ISOdate}"))
    |> timestamps_format()
    |> case do
      %{section: %Section{} = section} = map ->
        Map.put(
          map,
          :section,
          render_one(section, WebCATWeb.SectionView, "section.json")
        )

      map ->
        Map.delete(map, :section)
    end
    |> case do
      %{rotation_groups: groups} = map when is_list(groups) ->
        Map.put(
          map,
          :rotation_groups,
          render_many(groups, WebCATWeb.RotationGroupView, "group.json")
        )

      map ->
        Map.delete(map, :rotation_groups)
    end
    |> case do
      %{users: users} = map when is_list(users) ->
        Map.put(map, :users, render_many(users, WebCATWeb.UserView, "user.json"))

      map ->
        Map.delete(map, :users)
    end
  end
end
