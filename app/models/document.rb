class Document < ApplicationRecord
  # document.file.attach(io: File.open('/spec/fixtures/image.jpg'), filename: 'image.jpg')
  # document.file.purge
  has_one_attached :file do |attachable|
    attachable.variant :thumb, resize: "100x100"
  end

  # after_commit :ocr, on: :create

  # Ocr the image and send the contents to Open AI
  def ocr!
    ActiveRecord::Base.transaction do
      ::OcrService.perform(id)
    end
  end

  def upload!
    ActiveRecord::Base.transaction do
      ::DocumentUploadService.perform(id)
    end
  end

  def content?
    JSON.parse(content).empty?
  end

  def file_id?
    openai_file_id.nil?
  end
end
