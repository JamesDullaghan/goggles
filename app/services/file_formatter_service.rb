DELIMITERS = [',', ' ', "'", ":", "&amp;", "&quot;"]

# Format the contents of the file to match the expected json for use with Open AI
# document = Document.find(15)
# content = document.content
# FileFormatterService.perform(content)
class FileFormatterService
  attr_reader :content

  def initialize(content:)
    @content = content
  end

  # Return the open ai jsonl file structure
  #
  # @return {"text": "puppy A is happy", "metadata": "emotional state of puppy A"}
  def perform
    words = content.split(Regexp.union(DELIMITERS))

    # value.merge({ metadata: metadata }) if metadata.present?
    words.map do |element|
      return if element.blank?

      '{' + "\"text\":#{element.to_json}" + '}'
    end
  end

  def self.perform(content)
    service = FileFormatterService.new(content: content)
    service.perform
  end

  private

  # Possible to define metadata somewhere by enriching the word separated or defining where its coming from or something.
  #
  # @return [String]
  def metadata
    nil
  end
end
