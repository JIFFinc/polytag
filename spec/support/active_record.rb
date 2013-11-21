ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# require 'logger'
# ActiveRecord::Base.logger = Logger.new(STDOUT)
# ActiveRecord::Base.connection.disable_query_cache!

# Where is the migration file
migration_path = 'lib/generators/polytag/install/templates'
migration_file = File.join(GEM_DIR, migration_path, 'create_polytag_tables.rb')
require(migration_file)

# Run the migration file
CreatePolytagTables.up

ActiveRecord::Migration.create_table :taggables do |t|
  t.string :name
  t.timestamps
end

ActiveRecord::Migration.create_table :owners do |t|
  t.string :name
  t.timestamps
end
