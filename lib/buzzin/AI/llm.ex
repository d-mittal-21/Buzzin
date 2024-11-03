defmodule Buzzin.AI.LLM do
  def start_link do
    # Load TinyLlama - a much smaller model
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "TinyLlama/TinyLlama-1.1B-Chat-v1.0"})

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "TinyLlama/TinyLlama-1.1B-Chat-v1.0"})

    # Configure generation parameters directly in the serving
    serving =
      Bumblebee.Text.generation(model_info, tokenizer,
        max_new_tokens: 100,
        temperature: 0.7,
        top_k: 50,
        top_p: 0.9
      )
      |> Nx.Serving.batch()

    Application.put_env(:buzzin, :llm_serving, serving)

    {:ok, serving}
  end

  def generate_response(prompt) do
    serving = Application.get_env(:buzzin, :llm_serving)

    try do
      output = Nx.Serving.run(serving, prompt)
      {:ok, output.text}
    rescue
      e ->
        {:error, "Failed to generate response: #{Exception.message(e)}"}
    end
  end
end
