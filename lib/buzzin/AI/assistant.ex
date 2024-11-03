defmodule Buzzin.AI.Assistant do
  alias Buzzin.Messaging
  alias Buzzin.Repo
  import Ecto.Query

  def process_query(user_id, query) do
    # This is where we'll integrate with Llama
    case analyze_query(query) do
      {:analytics, phone_number, keyword} ->
        count_messages(user_id, phone_number, keyword)
      _ ->
        {:ok, "I'm not sure how to help with that. Try asking about your chat history!"}
    end
  end

  defp analyze_query(query) do
    # Simple pattern matching for now - could be more sophisticated
    cond do
      String.match?(query, ~r/how many times .* said? .* to (\d+)/) ->
        [_, phone_number, keyword] = Regex.run(~r/how many times .* said? (.*) to (\d+)/, query)
        {:analytics, phone_number, keyword}
      true ->
        :unknown
    end
  end

  defp count_messages(user_id, phone_number, keyword) do
    query = from m in Buzzin.Messaging.Message,
      join: r in assoc(m, :recipient),
      where: m.sender_id == ^user_id and
             r.phone_number == ^phone_number and
             ilike(m.body, ^"%#{keyword}%"),
      select: count(m.id)

    count = Repo.one(query)

    {:ok, "You have said '#{keyword}' to #{phone_number} #{count} times."}
  end
end
