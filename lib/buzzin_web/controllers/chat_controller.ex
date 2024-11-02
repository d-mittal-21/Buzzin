defmodule BuzzinWeb.ChatController do
  use BuzzinWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
