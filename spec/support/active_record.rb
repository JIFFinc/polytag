ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# ActiveRecord::Base.connection.disable_query_cache!
# ActiveRecord::Base.logger = Logger.new(STDOUT)

# Where is the migration file
migration_path = 'lib/generators/polytag/install/templates'
migration_file = File.join(GEM_DIR, migration_path, 'create_polytag_tables.rb')
require(migration_file)

# Run the migration file
CreatePolytagTables.up

[:ones, :twos, :threes, :fours].each do |table|
  ActiveRecord::Migration.create_table "test_taggable_#{table}" do |t|
    t.string :name
    t.timestamps
  end
end

ActiveRecord::Migration.create_table :owners do |t|
  t.string :name
  t.timestamps
end
