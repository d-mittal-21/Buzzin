defmodule BuzzinWeb.UserController do
  use BuzzinWeb, :controller
  alias Buzzin.Accounts

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User created successfully", user: %{
          id: user.id,
          phone_number: user.phone_number
        }})

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def login(conn, %{"phone_number" => phone, "password" => pass}) do
    case Accounts.authenticate_user(phone, pass) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)  # Store user_id in session
        |> put_status(:ok)
        |> json(%{
          message: "Login successful",
          user: %{id: user.id, phone_number: user.phone_number}
        })

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end

  def register_page(conn, _params) do
    render(conn, :register)
  end

  def login_page(conn, _params) do
    render(conn, :login)
  end
end
