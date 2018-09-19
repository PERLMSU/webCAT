defmodule WebCATWeb.NoteView do
  @moduledoc """
  Render notes
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Note

  def render("list.json", %{notes: notes}) do
    render_many(notes, __MODULE__, "note.json")
  end

  def render("show.json", %{note: note}) do
    render_one(note, __MODULE__, "note.json")
  end

  def render("note.json", %{note: %Note{} = note}) do
    note
    |> Map.from_struct()
    |> Map.take(~w(id content student_id observation_id rotation_group_id inserted_at updated_at)a)
  end
end
