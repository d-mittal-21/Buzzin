defmodule BuzzinWeb.MessageController do
  use BuzzinWeb, :controller
  alias Buzzin.Messaging

  def create(conn, params) do
    sender_id = conn.assigns.current_user_id

    case params do
      # New conversation with phone number
      %{"recipient_phone" => recipient_phone, "body" => body} ->
        case Messaging.start_conversation(sender_id, recipient_phone, body) do
          {:ok, message} ->
            conn
            |> put_status(:created)
            |> json(%{message: "Message sent", data: message})

          {:error, reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: reason})
        end

      # Message to existing conversation
      %{"recipient_id" => recipient_id, "body" => body} ->
        case Messaging.send_message(%{
          sender_id: sender_id,
          recipient_id: recipient_id,
          body: body
        }) do
          {:ok, message} ->
            conn
            |> put_status(:created)
            |> json(%{message: "Message sent", data: message})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: format_errors(changeset)})
        end
    end
  end

  def index(conn, %{"other_user_id" => other_user_id}) do
    sender_id = conn.assigns.current_user_id
    messages = Messaging.get_messages(sender_id, other_user_id)

    conn
    |> json(%{data: messages})
  end

  def conversations(conn, _params) do
    user_id = conn.assigns.current_user_id
    conversations = Messaging.get_conversations(user_id)

    conn
    |> json(%{data: conversations})
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
