defmodule BuzzinWeb.MessageController do
  use BuzzinWeb, :controller
  alias Buzzin.Messaging

  def create(conn, %{"recipient_phone" => recipient_phone, "message" => message}) do
    # TODO: Get actual user_id from session/token
    sender_id = get_session(conn, :user_id)

    case Messaging.start_conversation(sender_id, recipient_phone, message) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Message sent",
          data: %{
            id: message.id,
            body: message.body,
            inserted_at: message.inserted_at
          }
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})

      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: message})
    end
  end

  def index(conn, %{"other_user_id" => other_user_id}) do
    # TODO: Get actual user_id from session/token
    user_id = get_session(conn, :user_id)

    messages = Messaging.get_messages(user_id, other_user_id)

    conn
    |> json(%{data: messages})
  end

  def conversations(conn, _params) do
    # TODO: Get actual user_id from session/token
    user_id = get_session(conn, :user_id)

    conversations = Messaging.get_conversations(user_id)

    conn
    |> json(%{data: conversations})
  end
end
