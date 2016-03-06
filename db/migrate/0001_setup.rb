Sequel.migration do
	change do

		create_table(:users) do
			primary_key :id

			# don't bother with usernames, identify via email
			String      :email, null: false, index: { unique: true }

			String      :title
			String      :firstname, null: false
			String      :lastname, null: false

			# auth potentially via OpenID - may not have a local password
			# could always make one, maybe include in email verification mail
			String      :password_bcrypt, null: false

			# don't need complicated access levels just yet
			# is_admin=true enables everything
			TrueClass   :is_admin, null: false, default: false

			DateTime    :created_at, null: false
		end

		create_table(:tags) do
			primary_key :id

			String      :name, null: false, index: { unique: true }

			DateTime    :created_at, null: false
		end


		create_table(:cms_pages) do
			primary_key :id
			# See also published_id, added below.

			foreign_key :parent_id, :cms_pages, index: true

			String      :type, null: false
			String      :name, null: false

			DateTime    :created_at, null: false # initial page creation

			index [:type, :name], unique: true
		end

		# many-many join
		create_table(:cms_pages_tags) do
			primary_key :id

			# cascade: deleting a cms_page deletes associations
			foreign_key :cms_page_id, :cms_pages, null: false, on_delete: :cascade

			# cascade: deleting a tag deletes tag associations
			foreign_key :tag_id, :tags, null: false, on_delete: :cascade

			index [:cms_page_id, :tag_id ], unique: true
			index :tag_id
		end

		# new row for every save (if anything changed)
		# show the latest published_at version for a given cmd_page_id
		create_table(:cms_page_versions2) do
			primary_key :id

			# cascade: deleting a page should delete its versions
			foreign_key :cms_page_id, :cms_pages, null: false, on_delete: :cascade

			# If we delete a user, we probably don't want to delete all their content
			# as a side-effect.
			foreign_key :user_id, :users, null: false, on_delete: :restrict

			String      :display_title # title= text

			String      :content, text: true

			Integer     :version, null: false, default: 1

			DateTime    :created_at, null: false
			DateTime    :published_at

			index [:cms_page_id, :version], unique: true

			index Sequel.function(:to_tsvector, 'english', :content), type: :gin
		end

		alter_table(:cms_pages) do
			add_foreign_key :published_id, :cms_page_versions, on_delete: :set_null, unique: true
		end

	end
end
