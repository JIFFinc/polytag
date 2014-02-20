class CreatePolytagTables < ActiveRecord::Migration
  def self.up
    # Create the tags table
    create_table :polytag_tags do |t|
      t.string :name, index: true
      t.belongs_to :polytag_group, index: true
      t.timestamps
    end

     # Create the tag groups table
    create_table :polytag_groups do |t|
      t.string :name, index: true
      t.belongs_to :owner, polymorphic: true, index: true
      t.timestamps
    end

    # Create the tag group relations table
    create_table :polytag_connections do |t|
      t.belongs_to :polytag_tag, index: true
      t.belongs_to :polytag_group, index: true
      t.belongs_to :owner, polymorphic: true, index: true
      t.belongs_to :tagged, polymorphic: true, index: true
      t.timestamps
    end
  end

  def self.down
    drop_table :polytag_tags
    drop_table :polytag_groups
    drop_table :polytag_connections
  end
end
