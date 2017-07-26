# frozen_string_literal: true

class Tag < Sequel::Model
  many_to_many :cms_pages, order: :name

  def validate
    super

    validates_presence :name
    validates_unique :name, only_if_modified: true
  end
end
