module OpenaiService
  def self.generate_response(prompt, temperature, model_engine, max_tokens, freq_pen=0.0, pres_pen=0.0)
    access_token = Rails.application.credentials.dig(:openai, :access_token)
    client = OpenAI::Client.new(access_token: access_token)

    response = client.completions(
      parameters: {
        prompt: prompt,
        temperature: temperature,
        model: model_engine,
        max_tokens: max_tokens,
        frequency_penalty: freq_pen,
        presence_penalty: pres_pen
      }
    )
    response  # Return the entire response, not just the text
  end
end
