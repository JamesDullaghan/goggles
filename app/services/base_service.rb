class BaseService
  attr_reader :client

  def post_initialize
    @client ||= OpenAI::Client.new(access_token: Rails.application.secrets.openai_api_key)
  end
end
