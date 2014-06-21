require_relative 'db_connection'
require 'active_support/inflector'
#NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
#    of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= begin
      table = self.table_name
      data_output = DBConnection.execute2( "SELECT * FROM #{table}")
      column_names = data_output.first
    
      column_names.each do |column_name|
        define_method "#{column_name}" do
          attributes[column_name.to_sym]
        end
      
      
        define_method "#{column_name}=" do |item|
          attributes[column_name.to_sym] = item
        end
        
      end
    
      output = []
      column_names.map do |column|
        output << column.to_sym
      end
      output
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize    
  end

  def self.all
    items =  DBConnection.execute("SELECT * FROM #{table_name}") 
    self.parse_all(items)
                      
  end
  
  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
                                     SELECT
                                       *
                                     FROM
                                       #{table_name}
                                     WHERE
                                       id = (?)
                                     SQL
    self.parse_all(result).first
  end

  def attributes
    @attributes ||= {}    
  end

  def insert
    cols =  self.class.columns.join(', ')
    question_marks = (["?"] * 3).join(', ')
    vals =  attribute_values
    DBConnection.execute(<<-SQL, DBConnection.last_insert_row_id, *vals)
                            INSERT INTO
                              #{self.class.table_name} (#{cols})
                            VALUES
                              (#{question_marks})
                            SQL
    self.attributes[:id] = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.attributes[attr_name.to_sym] = value
    end

  end

  def save
    if self.attributes[:id].nil?
      self.insert
    else
      self.update
    end
  end

  def update
    set_line = self.attributes.map{|attr_name, value| "#{attr_name} = ?"}.join(', ')
    vals = attribute_values
    DBConnection.execute(<<-SQL, *vals, self.attributes[:id])
                            UPDATE
                              #{self.class.table_name}
                            SET
                              #{set_line}
                            WHERE
                              id = (?)
                            SQL
  end

  def attribute_values
    output = []
    self.attributes.map do |data_type|
      send(data_type.first)
    end
      
  end
end
