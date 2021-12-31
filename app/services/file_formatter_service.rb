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
    DELIMITERS = [',', ' ', "'", ":", "&amp;", "&quot;"]
    words = content.split(Regexp.union(DELIMITERS))

    words.map do |element|
      {
        "text" => element,
      }
    end
    # metadata: 'what goes here if anything?'
  end

  def self.perform(content)
    service = FileFormatterService.new(content: content)
    service.perform
  end
end
