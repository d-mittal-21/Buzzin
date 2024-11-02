defmodule Buzzin.Chats do
  import Ecto.Query
  alias Buzzin.Repo
  alias Buzzin.Messaging.Message
  alias Buzzin.Accounts.User

  @doc """
  Gets all chat conversations for a user.
  Returns a list of unique conversations with the last message and other user's details.
  """
  def get_user_chats(user_id) do
    # First, get all messages where user is either sender or recipient
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
  Creates a new chat by validating the recipient and sending the first message.
  """
  def create_chat(sender_id, recipient_phone, initial_message) do
    # First verify recipient exists
    case Repo.get_by(User, phone_number: recipient_phone) do
      nil ->
        {:error, "Recipient not found"}

      recipient ->
        # Don't allow messaging yourself
        if sender_id == recipient.id do
          {:error, "Cannot start chat with yourself"}
        else
          # Create the first message
          message_attrs = %{
            body: initial_message,
            sender_id: sender_id,
            recipient_id: recipient.id
          }

          case Buzzin.Messaging.send_message(message_attrs) do
            {:ok, message} -> {:ok, %{message: message, recipient: recipient}}
            {:error, changeset} -> {:error, changeset}
          end
        end
    end
  end

  @doc """
  Gets all messages between two users, ordered by timestamp.
  """
  def get_messages(user_id, other_user_id) do
    messages = from m in Message,
      where: (m.sender_id == ^user_id and m.recipient_id == ^other_user_id) or
             (m.sender_id == ^other_user_id and m.recipient_id == ^user_id),
      order_by: [asc: m.inserted_at],
      select: %{
        id: m.id,
        body: m.body,
        sender_id: m.sender_id,
        recipient_id: m.recipient_id,
        inserted_at: m.inserted_at
      }

    Repo.all(messages)
  end

  @doc """
  Checks if a chat exists between two users
  """
  def chat_exists?(user_id, other_user_id) do
    query = from m in Message,
      where: (m.sender_id == ^user_id and m.recipient_id == ^other_user_id) or
             (m.sender_id == ^other_user_id and m.recipient_id == ^user_id),
      limit: 1

    Repo.exists?(query)
  end
end
