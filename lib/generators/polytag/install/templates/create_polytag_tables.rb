class CreatePolytagTables < ActiveRecord::Migration
  def self.up
    # Create the tags table
    create_table :polytag_tags do |t|
      t.string :name, index: true
      t.belongs_to :polytag_tag_group, index: true
      t.timestamps
    end

     # Create the tag groups table
    create_table :polytag_tag_groups do |t|
      t.string :name, index: true
      t.belongs_to :owner, polymorphic: true, index: true
      t.timestamps
    end

    # Create the tag group relations table
    create_table :polytag_connections do |t|
      t.belongs_to :polytag_tag, index: true
      t.belongs_to :polytag_tag_group, index: true
      t.belongs_to :owner, polymorphic: true, index: true
      t.belongs_to :tagged, polymorphic: true, index: true
      t.timestamps
    end

    # Index for the category and name
    add_index :polytag_tags, [:polytag_tag_group_id, :name],
      name: :polytag_tags_unique,
      unique: true

    add_index :polytag_tag_groups,
      [:owner_type, :owner_id, :name],
      name: :polytag_tag_groups_unique,
      unique: true

    add_index :polytag_connections,
      [:polytag_tag_id, :polytag_tag_group_id, :owner_type, :owner_id, :tagged_type, :tagged_id],
      name: :polytag_connections_unique,
      unique: true
  end

  def self.down
    drop_table :polytag_tags
    drop_table :polytag_tag_groups
    drop_table :polytag_tag_connections
  end
end
