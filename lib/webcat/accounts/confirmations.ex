defmodule WebCAT.Accounts.Confirmations do
  @moduledoc """
  Utility functions for working with user confirmations
  """

  alias WebCAT.Repo
  alias WebCAT.Accounts.Confirmation


  def get(token) do
    case Repo.get_by(Confirmation, token: token) do
      %Confirmation{} = confirmation -> {:ok, confirmation}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Confirm a user based on a token
  """
  @spec confirm(String.t()) :: {:ok, Confirmation.t()} | {:error, any}
  def confirm(token) do
    case Repo.get_by(Confirmation, token: token) do
      %Confirmation{} = confirmation ->
        if confirmation.verified do
          {:error, :bad_request}
        else
          confirmation
          |> Confirmation.changeset(%{verified: true})
          |> Repo.update()
        end

      nil ->
        {:error, :not_found}
    end
  end

end
