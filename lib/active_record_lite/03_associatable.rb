require_relative '02_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )
  
  def initialize
    @options[:primary_key] = :id
  end

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
    
  end


end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
          :foreign_key => "#{name}_id".to_sym,
          :class_name => name.to_s.camelcase,
          :primary_key => :id
        }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id
    }
    
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method "#{name}" do
      f_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(id: f_key).first
    end
  end

  def has_many(name, options = {})
    class_name = self.send(class_name)
    options = HasManyOptions.new(name, class_name, options)
    define_method "#{name}" do
      f_key = options.foreign_key
      target_class.where(id: f_key).first
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
