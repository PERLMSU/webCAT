defmodule WebCAT.Feedback do
  alias WebCAT.Accounts.User

  @behaviour Bodyguard.Policy

  def authorize(action, _user, _)
      when action in ~w(show_category list_categories list_category_observations)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_draft list_drafts create_draft update_draft delete_draft)a,
      do: true

  def authorize(action, _user, _) when action in ~w(create_email show_email)a, do: true

  def authorize(action, _user, _)
      when action in ~w(show_explanation list_explanations create_explanation update_explanation delete_explanation)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_note list_notes create_note update_note delete_note)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_observation list_observations create_observation update_observation delete_observation list_observation_explanations list_observation_notes)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_category update_category delete_category)a,
      do: true

  @doc """
  Deny catch-all
  """
  def authorize(_, _, _), do: false
end
