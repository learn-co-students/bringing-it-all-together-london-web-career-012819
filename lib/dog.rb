class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self

  end

  def update
    sql = "UPDATE dogs SET id = ?, name = ?, breed = ?;"
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog = DB[:conn].execute(sql, name, breed)

    if dog.empty?
      self.create(name: name, breed: breed)
    else
      dog_data = dog[0]
      Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    end
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end

  def self.new_from_db(dog_row)
    Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    data = DB[:conn].execute(sql, id)[0]
    self.new_from_db(data)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    data = DB[:conn].execute(sql, name)[0]
    self.new_from_db(data)
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end
end
