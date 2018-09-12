defmodule WebCATWeb.Auth.Guardian do
  use Guardian, otp_app: :webcat

  alias WebCAT.CRUD
  alias WebCAT.Accounts.User

  @spec subject_for_token(User.t(), map()) :: {:error, String.t()} | {:ok, any()}
  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "unknown resource type"}
  end

  @spec resource_from_claims(map()) :: {:error, any()} | {:ok, any()}
  def resource_from_claims(%{"sub" => user_id}) do
    CRUD.get(User, user_id)
  end

  def resource_from_claims(_claims) do
    {:error, "unknown resource type"}
  end
end
