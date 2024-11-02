defmodule BuzzinWeb.UserController do
  use BuzzinWeb, :controller
  alias Buzzin.Accounts

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User created successfully", user: user})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset})
    end
  end

  def login(conn, %{"phone_number" => phone, "password" => pass}) do
    case Accounts.authenticate_user(phone, pass) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Login successful", user: user})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end
end
