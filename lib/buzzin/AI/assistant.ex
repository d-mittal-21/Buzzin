defmodule Buzzin.AI.Assistant do
  alias Buzzin.Messaging
  alias Buzzin.Repo
  import Ecto.Query

  def process_query(user_id, query) do
    # First try to match specific analytics patterns
    case analyze_specific_query(user_id, query) do
      {:ok, response} ->
        {:ok, response}
      :unknown ->
        # If no specific pattern matches, use LLM for general response
        chat_context = get_basic_stats(user_id)
        prompt = create_simple_prompt(chat_context, query)
        Buzzin.AI.LLM.generate_response(prompt)
    end
  end

  defp analyze_specific_query(user_id, query) do
    cond do
      String.match?(query, ~r/how many messages/i) ->
        count_total_messages(user_id)

      Regex.match?(~r/how many times .* said? .* to (\d+)/i, query) ->
        [_, keyword, phone] = Regex.run(~r/how many times .* said? (.*) to (\d+)/i, query)
        count_specific_messages(user_id, phone, keyword)

      true ->
        :unknown
    end
  end

  defp count_total_messages(user_id) do
    count = from(m in Buzzin.Messaging.Message,
      where: m.sender_id == ^user_id,
      select: count(m.id)
    ) |> Repo.one()

    {:ok, "You have sent a total of #{count} messages."}
  end

  defp count_specific_messages(user_id, phone_number, keyword) do
    count = from(m in Buzzin.Messaging.Message,
      join: r in assoc(m, :recipient),
      where: m.sender_id == ^user_id and
             r.phone_number == ^phone_number and
             ilike(m.body, ^"%#{keyword}%"),
      select: count(m.id)
    ) |> Repo.one()

    {:ok, "You have said '#{keyword}' to #{phone_number} #{count} times."}
  end

  defp get_basic_stats(user_id) do
    # Get total messages sent
    total_messages = from(m in Buzzin.Messaging.Message,
      where: m.sender_id == ^user_id,
      select: count(m.id)
    ) |> Repo.one()

    # Get unique recipients count (fixed query)
    unique_contacts = from(m in Buzzin.Messaging.Message,
      where: m.sender_id == ^user_id,
      select: fragment("COUNT(DISTINCT ?)", m.recipient_id)
    ) |> Repo.one()

    # Get most messaged contact
    most_active_contact = from(m in Buzzin.Messaging.Message,
      join: r in assoc(m, :recipient),
      where: m.sender_id == ^user_id,
      group_by: [r.phone_number],
      select: {r.phone_number, count(m.id)},
      order_by: [desc: count(m.id)],
      limit: 1
    ) |> Repo.one()

    most_active_text = case most_active_contact do
      {phone, count} -> "Most messaged contact is #{phone} with #{count} messages."
      nil -> "No messages sent yet."
    end

    """
    Chat Analysis:
    - Total messages sent: #{total_messages}
    - Number of contacts: #{unique_contacts}
    - #{most_active_text}
    """
  end

  defp create_simple_prompt(context, query) do
    """
    Based on this chat history analysis:
    #{context}

    User Question: #{query}

    Please provide a brief and helpful response focusing on the statistics provided.
    """
  end
end
