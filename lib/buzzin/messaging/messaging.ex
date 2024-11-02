defmodule Buzzin.Messaging do
  import Ecto.Query
  alias Buzzin.Repo
  alias Buzzin.Messaging.Message
  alias Buzzin.Accounts.User

  def send_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets all conversations for a user with the latest message
  """
  def get_conversations(user_id) do
    messages_query = from m in Message,
      where: m.sender_id == ^user_id or m.recipient_id == ^user_id,
      order_by: [desc: m.inserted_at]

    # Get the latest message for each conversation
    latest_messages = from m in messages_query,
      join: other_user in User,
      on: (m.sender_id == other_user.id and m.sender_id != ^user_id) or
          (m.recipient_id == other_user.id and m.recipient_id != ^user_id),
      select: %{
        other_user: %{
          id: other_user.id,
          phone_number: other_user.phone_number
        },
        last_message: %{
          id: m.id,
          body: m.body,
          inserted_at: m.inserted_at,
          sender_id: m.sender_id
        }
      },
      distinct: [other_user.id],
      order_by: [desc: m.inserted_at]

    Repo.all(latest_messages)
  end

  @doc """
  Gets all messages between two users
  """
  def get_messages(user_id, other_user_id) do
    Message
    |> where([m],
      (m.sender_id == ^user_id and m.recipient_id == ^other_user_id) or
      (m.sender_id == ^other_user_id and m.recipient_id == ^user_id)
    )
    |> order_by([m], asc: m.inserted_at)
    |> preload([:sender, :recipient])
    |> Repo.all()
  end

  @doc """
  Starts a new conversation with a user by phone number
  """
  def start_conversation(sender_id, recipient_phone, message_body) do
    with {:ok, recipient} <- get_recipient(recipient_phone),
         false <- sender_id == recipient.id do
      send_message(%{
        sender_id: sender_id,
        recipient_id: recipient.id,
        body: message_body
      })
    else
      nil -> {:error, "Recipient not found"}
      true -> {:error, "Cannot send message to yourself"}
      error -> error
    end
  end

  defp get_recipient(phone_number) do
    case Repo.get_by(User, phone_number: phone_number) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
