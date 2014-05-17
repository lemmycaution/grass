class CreateGrassPairs < ActiveRecord::Migration
  def change
    create_table :grass_pairs, id: false do |t|
      t.column    :keyid, :string, null: false, index: true, primary: true 
      t.column    :dir, :string
      t.column    :path, :string
      t.column    :locale, :string
      t.column    :format, :string
      t.column    :handler, :string
      t.column    :filepath, :string      

      t.column    :raw, :text
      t.column    :result, :text      
      t.column    :binary, :oid, limit: 2147483648 #:binary      
      
      t.column    :pairs, :string, default: []
      t.column    :hidden, :boolean, default: false
      t.column    :mime_type, :string
      
      t.column    :etag, :string

      t.timestamps
    end
    add_index :grass_pairs, [:locale,:dir,:path]
  end
end