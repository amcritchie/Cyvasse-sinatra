class UsersTable
  def initialize(database_connection)
    @database_connection = database_connection
  end

  def create(first_name, last_name, email, username, password)
    insert_user_sql = <<-SQL
      INSERT INTO users (first_name, last_name, email, username, password)
      VALUES ('#{first_name}', '#{last_name}', '#{email}', '#{username}', '#{password}')
      RETURNING id
    SQL

    @database_connection.sql(insert_user_sql).first["id"]
  end

  def find(user_id)
    find_sql = <<-SQL
      SELECT * FROM users
      WHERE id = #{user_id}
    SQL

    @database_connection.sql(find_sql).first
  end

  def find_first_name(user_id)
    first_name_sql = <<-SQL
      SELECT first_name FROM users
      WHERE id = #{user_id}
    SQL

    p @database_connection.sql(first_name_sql).first
  end

  def find_user(username)
    find_sql = <<-SQL
      SELECT id FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(find_sql)
  end

  def users
    users_sql = <<-SQL
      SELECT username, id FROM users
    SQL

    @database_connection.sql(users_sql)
  end

  def find_by(username, password)
    find_by_sql = <<-SQL
      SELECT * FROM users
      WHERE username = '#{username}'
      AND password = '#{password}'
    SQL

    @database_connection.sql(find_by_sql).first
  end

  def find_username(username)
    find_username = <<-SQL
      SELECT * FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(find_username).first
  end

  def find_password(username)
    find_password = <<-SQL
      SELECT password FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(find_password).first
  end

  def delete_user(username)
    delete_user_sql = <<-SQL
      DELETE FROM users
      WHERE username = '#{username}'
    SQL

    @database_connection.sql(delete_user_sql)
  end

  def delete(id)
    delete_sql = <<-SQL
    DELETE
    FROM trees
    WHERE id = #{id}
    SQL

    database_connection.sql(delete_sql)
  end

end