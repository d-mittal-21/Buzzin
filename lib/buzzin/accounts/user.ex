defmodule Buzzin.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2, as: PasswordHasher

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

  def put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      change(changeset, password_hash: PasswordHasher.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
