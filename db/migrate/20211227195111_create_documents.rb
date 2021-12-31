class CreateDocuments < ActiveRecord::Migration[7.0]
  def up
    create_table :documents do |t|
      t.jsonb :content, default: '{}', null: false
      t.timestamps
    end
  end

  def down
    drop_table :documents
  end
end
