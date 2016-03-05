class CmsPage < Sequel::Model
	plugin :rcte_tree, order: :name, descendants: {order: :name}

	one_to_many :versions, class: :CmsPageVersion, order: Sequel.desc(:version)
	one_to_one  :latest_version, clone: :versions
	one_to_one  :first_version, clone: :versions, conditions: {version: 1}

	one_to_many :published, clone: :versions, conditions: {published_at: Sequel::NOTNULL}, order: Sequel.desc(:published_at)

	many_to_one :latest_published, class: :CmsPageVersion, key: :published_id

	many_to_many :tags, order: :name

	subset :blog, {type: 'blog'}
	subset :page, {type: 'page'}

	subset :published, {published_id: Sequel::NOTNULL}


	dataset_module do
		def complete_name(q)
			column = :name
			where("? % ?", column, q).or(Sequel.ilike(column, "#{q}%"))
		end

		# returns array of :m and :count for pages created in each month
		# useful for blog post sidebar
		def group_by_month
			m = Sequel.as(Sequel.function(:date_trunc, 'month', :created_at), :m)
			select(m).group_and_count(m).reverse(:m)
		end
	end

	def set_tags(new_tags)
		old_tags = tags.map(&:name) # existing tags
		new_tags = new_tags.map{|m| m.strip } # remove leading/trailing spaces

		# delete tags in old_tags but not new_tags
		old_tags.each do |name|
			unless new_tags.include? name
				remove_tag(Tag[name: name])
			end
		end

		# add tags in tag_array but not old_tags
		new_tags.each do |name|
			unless old_tags.include? name
				tag = Tag.find_or_create(name: name)
				add_tag(tag)
			end
		end
	end

	def version(v)
		versions_dataset[version: v]
	end

	def validate
		super

		validates_presence [:type, :name]
		validates_unique [:type, :name], only_if_modified: true
	end

	def latest_visible(user)
		# try and hide away some logic for deciding which is the latest
		# version of a page, depending if the user is an admin or not.
		user&.is_admin? ? latest_version : latest_published
	end

	# class variable used by Kramdown::Converter::NabuHtml to check if
	# a page exists for styling purposes. I just #clear the Set when
	# changes might be made and then .page_cache will handle refreshing it.
	@@page_cache = Set.new
	class << self
		def page_cache
			@@page_cache.empty? ? refresh_page_cache : @@page_cache
		end

		def refresh_page_cache
			# clearing and merging is about twice as fast as making a new Set.
			# the #clear is usually superfluous as we're normally called
			# when empty, but better safe than sorry.
			@@page_cache.clear
			@@page_cache.merge all.map(&:name)
		end
	end
end
