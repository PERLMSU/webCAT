defmodule WebCAT.Rotations do
  alias WebCAT.Accounts.User

  @behaviour Bodyguard.Policy


  @doc """
  Deny catch-all
  """
  def authorize(_, _, _), do: false
end
