class CreatePolytagTables < ActiveRecord::Migration
  def self.up
    # Create the tags table
    create_table :_polytags do |t|
      t.string :category
      t.string :name
      t.timestamps
    end

    # Create the relations table
    create_table :_polytag_relations do |t|
      t.belongs_to :tagged, polymorphic: true, index: true
      t.belongs_to :_polytags, index: true
      t.timestamps
    end

    # Index for the category and name
    add_index :_polytags, [:category, :name], unique: true
  end

  def self.down
    drop_table :_polytags
    drop_table :_polytag_relations
  end
end
