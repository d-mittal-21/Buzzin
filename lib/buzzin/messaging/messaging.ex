defmodule Buzzin.Messaging do
  alias Buzzin.Repo
  alias Buzzin.Messaging.Message

  def send_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end
end
