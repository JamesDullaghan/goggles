# String path for the uploaded document
# document = Document.first
# OcrService.perform(document.id)
# OcrService.new(document_id: document.id).perform
class OcrService
  attr_reader :file, :tempfile, :document

  def initialize(document_id:)
    @document = Document.find_by(id: document_id)
    @file = @document.file
    @tempfile = Tempfile.new(@file.name, encoding: 'ascii-8bit')
  end

  def perform
    begin
      file_contents = file.download
      tempfile << file_contents
      document.update(content: json)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def self.perform(id)
    service = ::OcrService.new(document_id: id)
    service.perform
  end

  private

  def response
    @_response ||= RTesseract.new(tempfile.path)
  end

  def box
    @_box ||= response.to_box
  end

  def json
    @_json ||= box.to_json
  end
end
