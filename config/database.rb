APP_ROOT = File.expand_path '..', __dir__ unless defined?(APP_ROOT)
RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)

# if bundler hasn't been setup yet, so do (rake migration task)
# (everything else will get this from boot.rb)
if require 'bundler'
	Bundler.setup(:default, RACK_ENV)
end

require 'sequel'

Sequel.extension :migration
Sequel.extension :pg_inet_ops

# Master +Sequel::Database+ object. All models inherit this.
DB = Sequel.connect adapter: 'postgres',
	hostname: 'localhost', database: 'nabu',
	username: 'nabu', password: 'nabu',
	max_connections: 50

DB.extension :null_dataset
DB.extension :pagination

DB.extension :pg_enum
DB.extension :pg_inet
DB.extension :pg_json
DB.extension :pg_range

DB.optimize_model_load = true

# this might be a win in the distant future when the schema barely ever changes
#DB.extension :schema_caching
#DB.load_schema_cache? File.expand_path(File.join(APP_ROOT, 'tmp', 'schema.cache'))

# this is to stop code reloading breaking when a model changes.
# see http://sequel.jeremyevans.net/rdoc/classes/Sequel/Model/Associations/ClassMethods.html#attribute-i-cache_associations
Sequel::Model.cache_associations = false if development?

# be less bitchy in set()
Sequel::Model.strict_param_setting = false

Sequel::Model.plugin :schema
Sequel::Model.plugin :validation_helpers
# removed; doing validations manually for now.
#Sequel::Model.plugin :auto_validations, not_null: :presence, unique_opts: {only_if_modified: true}

# pull in defaults for new instances from database DEFAULT values
Sequel::Model.plugin :defaults_setter

# Auto-manage created_at/updated_at fields.
# There are actually database defaults but this stops validations getting
# upset that the fields aren't set, and also manages updated_at for us.
# We set the option to set updated_at on creation. This avoids having to deal
# with NULLs; if you want to check a field has never been updated (which in
# practise is a much rarer requirement) check for created_at == updated_at
Sequel::Model.plugin :timestamps, update_on_create: true

# better changed_columns support
Sequel::Model.plugin :dirty

# add attribute? readers for all booleans in all models
Sequel::Model.plugin :boolean_readers

Sequel::Model.plugin :tactical_eager_loading
