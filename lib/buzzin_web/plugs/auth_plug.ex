defmodule BuzzinWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Please log in first"})
        |> halt()
      user_id ->
        assign(conn, :current_user_id, user_id)
    end
  end
end
