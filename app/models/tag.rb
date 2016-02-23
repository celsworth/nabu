class Tag < Sequel::Model
	many_to_many :cms_pages

	dataset_module do
		def complete_name(q)
			column = :name
			where("? % ?", column, q).or(Sequel.ilike(column, "#{q}%"))
		end
	end

	def validate
		super

		validates_presence :name
		validates_unique :name, only_if_modified: true
	end

end
