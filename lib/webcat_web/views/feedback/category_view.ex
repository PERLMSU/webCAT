defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.Category
  alias WebCAT.Rotations.Classroom
  alias WebCATWeb.{ClassroomView, ObservationView}

  def render("list.json", %{categories: categories}) do
    render_many(categories, __MODULE__, "category.json")
  end

  def render("show.json", %{category: category}) do
    render_one(category, __MODULE__, "category.json")
  end

  def render("category.json", %{category: %Category{} = category}) do
    category
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{parent_category: %Category{} = parent_category} = map ->
        Map.put(map, :parent_category, render_one(parent_category, __MODULE__, "category.json"))

      map ->
        Map.delete(map, :parent_category)
    end
    |> case do
      %{classroom: %Classroom{} = classroom} = map ->
        Map.put(map, :classroom, render_one(classroom, ClassroomView, "classroom.json"))

      map ->
        Map.delete(map, :classroom)
    end
    |> case do
      %{sub_categories: sub_categories} = map when is_list(sub_categories) ->
        Map.put(map, :sub_categories, render_many(sub_categories, __MODULE__, "category.json"))

      map ->
        Map.delete(map, :sub_categories)
    end
    |> case do
      %{observations: observations} = map when is_list(observations) ->
        Map.put(map, :observations, render_many(observations, ObservationView, "category.json"))

      map ->
        Map.delete(map, :observations)
    end
  end
end
