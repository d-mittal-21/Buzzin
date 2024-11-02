defmodule Buzzin.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :phone_number, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:phone_number, :password])
    |> validate_required([:phone_number, :password])
    |> unique_constraint(:phone_number)
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  # Temporary simple hashing (NOT FOR PRODUCTION!)
  def put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      # Simply reverse the string as a "hash" (FOR DEVELOPMENT ONLY!)
      hash = String.reverse(password)
      change(changeset, password_hash: hash)
    else
      changeset
    end
  end
end
