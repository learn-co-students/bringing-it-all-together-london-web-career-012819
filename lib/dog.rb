require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    rows = DB[:conn].execute(sql, id)
    rows.map do |row|
      Dog.new(name: row[1], breed: row[2], id: row[0])
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      data = dog[0]
      dog = Dog.new(name: data[1], breed: data[2], id: data[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    rows = DB[:conn].execute(sql, name)
    rows.map do |row|
      Dog.new(name: row[1], breed: row[2], id: row[0])
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end

end
