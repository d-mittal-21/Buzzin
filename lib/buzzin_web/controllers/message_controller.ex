defmodule BuzzinWeb.MessageController do
  use BuzzinWeb, :controller
  alias Buzzin.Messaging

  def create(conn, %{"sender_id" => sender_id, "recipient_id" => recipient_id, "body" => body}) do
    case Messaging.send_message(%{sender_id: sender_id, recipient_id: recipient_id, body: body}) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> json(%{message: "Message sent", data: message})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset})
    end
  end
end
