# document = Document.first
# DocumentUploadService.perform(document.id, 'answers')
# Upload the OCR'd document contents to Open-AI for use in different services
# Classification and Answers for starters
class DocumentUploadService < BaseService
  attr_reader :document, :filename, :json, :purpose

  class DocumentUploadError < StandardError
    def initialize(msg="Attached document has no associated file")
      super
    end
  end

  class DocumentContentError < StandardError
    def initialize(msg="Content not associated with the correct document. Try rerunning the ocr service to get valid content from tesseract")
      super
    end
  end

  def initialize(document_id:, purpose:)
    @document = Document.find_by(id: document_id)
    @file = @document.file

    raise DocumentUploadError.new unless @file.present?

    @filename = @file.name
    @purpose = purpose
    @content = @document&.content

    DocumentContentError.new unless @content.present?

    @json = JSON.parse(@content)

    # Get the client
    post_initialize
  end

  # Format the file and upload the files to OpenAI and update the uploaded file ID
  def perform
    ActiveRecord::Base.transaction do
      begin
        formatted_file
        response = client.files.upload(parameters: { file: "#{filename}.jsonl", purpose: purpose })
        openai_file_id = response.fetch('id', nil)
        status = response.fetch('status', 'pending')

        if status.eql?('uploaded')
          document.update(openai_file_id: openai_file_id)
        end
      ensure
         # File.delete("#{filename}.jsonl")
      end
    end
  end

  def self.perform(id, purpose = 'answers')
    service = DocumentUploadService.new(document_id: id, purpose: purpose)
    service.perform
  end

  private

  # The content supplied from the file upload joined with spaces as a big text blob!
  #
  # @return [String]
  def document_content
    @_document_content ||= json.map { |content| content['word'] }.join(' ')
  end

  # The formatting of the OCR'd file
  #
  # @return [String]
  def formatted_contents
    @_formatted_contents ||= ::FileFormatterService.perform(document_content)
  end

  # The formatted file output written to the file
  # zero true = empty
  # zero false = not empty
  #
  # @return [Integer]
  def formatted_file
    return File.read("#{filename}.jsonl") if File.exist?("#{filename}.jsonl")

    @_formatted_file ||= File.open("#{filename}.jsonl", 'w+') do |file|
      file.puts(formatted_contents)
    end
  end
end
