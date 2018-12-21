defmodule WebCAT.Accounts.Notifications do
  @moduledoc """
  Utility functions for working with user notifications
  """

  alias WebCAT.Accounts.Notification
  alias WebCAT.Repo
  import Ecto.Query

  @doc """
  Mark a notification seen
  """
  @spec mark_seen(integer() | WebCAT.Accounts.Notification.t()) :: {:ok}
  def mark_seen(%Notification{id: id, seen: seen}) do
    if not seen do
      mark_seen(id)
    else
      {:ok}
    end
  end

  def mark_seen(id) when is_integer(id) do
    Notification
    |> where([n], n.id == ^id)
    |> update(set: [seen: true])
    |> Repo.update_all([])

    {:ok}
  end

  @doc """
  Create a new notification
  """
  @spec create(String.t(), integer(), integer()) ::
          {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def create(content, draft_id, user_id) when is_integer(draft_id) and is_integer(user_id) do
    %Notification{}
    |> Notification.changeset(%{content: content, draft_id: draft_id, user_id: user_id})
    |> Repo.insert()
  end
end
