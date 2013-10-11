class CreatePolytagTables < ActiveRecord::Migration
  def self.up
    # Create the tags table
    create_table :polytag_tags do |t|
      t.belongs_to :polytag_tag_group, index:true, null: true, default: nil
      t.string :name, index: true
      t.timestamps
    end

    # Create the relations table
    create_table :polytag_tag_relations do |t|
      t.belongs_to :tagged, polymorphic: true, index: true
      t.belongs_to :polytag_tag, index: true
      t.timestamps
    end

     # Create the tag groups table
    create_table :polytag_tag_groups do |t|
      t.belongs_to :owner, polymorphic: true, index: true
      t.string :name, index: true, null: true, default: nil
      t.timestamps
    end

    # Index for the category and name
    add_index :polytag_tags, [:polytag_tag_group_id, :name], unique: true
    add_index :polytag_tag_groups, [:owner_type, :owner_id, :name], unique: true
  end

  def self.down
    drop_table :polytag_tags
    drop_table :polytag_tag_relations
  end
end
