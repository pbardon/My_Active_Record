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
    p @options
    @options[:class_name].constantize
  end

  def table_name
    model_class.to_s.underscore + "s"
    
  end
  
  def foreign_key
    @options[:foreign_key]
  end

  def primary_key
    @options[:primary_key]
  end

  def class_name
    @options[:class_name]
  end

end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @options = options
    if @options[:foreign_key] == nil || @options[:class_name] == nil
      @options[:foreign_key] ||= "#{name}_id".to_sym
      @options[:class_name] ||= "#{name.to_s.camelcase}"
      super()
    end
    @options
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @options = options
    if @options[:foreign_key] == nil || @options[:class_name] == nil
      @options[:foreign_key] ||= (self_class_name.downcase + "_id").to_sym
      @options[:class_name] ||= name.to_s.singularize.camelcase
      super()
    else
      @options
    end
    @options
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
    options = BelongsToOptions.new(name, options)
    define_method "#{name}" do
      f_key = options.foreign_key
      target_class = options.model_class
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
