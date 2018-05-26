require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
  # creates a downcased, plural table name based on the Class name
    self.to_s.downcase.pluralize
    # "#{self.to_s.downcase}s"
  end

  def self.column_names
  # returns an array of SQL column names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
  # creates an new instance of a student
  # creates a new student with attributes
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

# has instance methods to insert data into db

  def table_name_for_insert
  # return the table name when called on an instance of Student
    self.class.table_name
  end

  def col_names_for_insert
  # return the column names when called on an instance of Student
  # does not include an id column
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
  # formats the column names to be used in a SQL statement
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
  # saves the student to the db
  # sets the student\'s id
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
  # executes the SQL to find a row by name
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

#  def self.find_by(attribute_hash)
  # executes the SQL to find a row by the attribute passed into the method
  # accounts for when an attribute value is an integer
#    value = attribute_hash.values.first
#    formatted_value = value.class == Fixnum ? value : "'#{value}'"
#    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
#    DB[:conn].execute(sql)
#  end

end
