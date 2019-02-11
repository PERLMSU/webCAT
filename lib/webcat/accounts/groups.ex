defmodule WebCAT.Accounts.Groups do
  def has_group?(groups, name) when is_list(groups) do
    Enum.any?(groups, fn group -> group.name == name end)
  end

  def has_group?(_, _), do: false
end
