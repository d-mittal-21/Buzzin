defmodule BuzzinWeb.AIController do
  use BuzzinWeb, :controller
  alias Buzzin.AI.Assistant

  def chat(conn, %{"message" => message}) do
    user_id = conn.assigns.current_user_id

    case Assistant.process_query(user_id, message) do
      {:ok, response} ->
        json(conn, %{response: response})
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error})
    end
  end
end
