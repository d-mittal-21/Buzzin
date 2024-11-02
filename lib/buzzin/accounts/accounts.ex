defmodule Buzzin.Accounts do
  alias Buzzin.Repo
  alias Buzzin.Accounts.User

  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(phone_number, password) do
    user = Repo.get_by(User, phone_number: phone_number)

    cond do
      # Simple reverse string comparison (FOR DEVELOPMENT ONLY!)
      user && String.reverse(password) == user.password_hash ->
        {:ok, user}

      true ->
        {:error, "Invalid phone number or password"}
    end
  end
end
