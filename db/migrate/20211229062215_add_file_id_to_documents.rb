class AddFileIdToDocuments < ActiveRecord::Migration[7.0]
  def up
    add_column :documents, :openai_file_id, :string
  end

  def down
    remove_column :documents, :openai_file_id
  end
end
