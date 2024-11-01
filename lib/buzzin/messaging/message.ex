defmodule Buzzin.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    belongs_to :sender, Buzzin.Accounts.User
    belongs_to :recipient, Buzzin.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :sender_id, :recipient_id])
    |> validate_required([:body, :sender_id, :recipient_id])
  end
end
