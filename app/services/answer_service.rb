require "ruby/openai"

# question = "which puppy is happy?"
# text = "What is the meaning of life?"
# documents = "file_id"
# model = "curie"

# service = ::AnswerService.new(
#   question: question
#   documents: documents,
#   model: "curie",
#   file: "file_id"
# )
# service.perform

# response = client.answers(parameters: {
#   documents: ["Puppy A is happy.", "Puppy B is sad."],
#   question: "which puppy is happy?",
#   model: "curie",
# })

class AnswerService < BaseService
  attr_reader :documents,
              :file,
              :model,
              :question

  # Initialization of the Answer service object
  # Documents being pre-uploaded documents
  # file is a single file with an ID being passed to be used to find an answer
  # Question is the question being asked that needs an answer
  # The model to use during the question/answer phase
  def initialize(question:, model:, documents: nil, file: nil)
    @question = question
    @model = model
    @documents = documents
    @file = file

    post_initialize()
  end

  def perform
    return if question?

    response = client.answers(parameters: params)

    if response.present?
      response.body
    end
  rescue HTTParty::ResponseError, HTTParty::Error => e
    Rails.logger.error('There was an issue with the request to Open AI')
  end

  def self.perform(documents, question, model = "curie")
    service = ::AnswerService.new(
      documents: documents,
      question: question,
      model: model,
    )
    service.perform
  end

  private

  # Do not act on the service if there is no question
  #
  # @return [Boolean]
  def question?
    question.empty?
  end

  # Parameters being passed to the open-ai answers endpoint
  #
  # https://beta.openai.com/docs/api-reference/answers/create?lang=python
  # @return [Hash]
  def params
    params = {
      question: question,
      model: model,
    }

    params = params.merge({ documents: documents }) if documents.present?
    params = params.merge({ file: file }) if file.present?

    params
  end
end
