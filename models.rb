def connect_to_db()
    db = SQLite3::Database.new("db/ovning_urval.db")
    db.results_as_hash = true
    db
end

def get_users()
    db = connect_to_db
    db.execute("SELECT * FROM user")
end

def get_diets()
    db = connect_to_db
    db.execute("SELECT diets.*, user.name AS user_name FROM diets JOIN user ON diets.UserID = user.ID")
end

def get_results(username)
    db = connect_to_db
    db.execute("SELECT * FROM user WHERE name = ?", username).first
end

def get_register_form(username, password_digest, email)
    db = connect_to_db
    db.execute("INSERT INTO user (name, password, email, admin) VALUES (?, ?, ?, 0)", username, password_digest, email)
end 

def save_plans(user_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
    db = connect_to_db
    db.execute("INSERT INTO plans (UserID, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", user_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
end

def save_diet(diet_name, diet_info, user_id, name)
    db = connect_to_db
    db.execute("INSERT INTO diets (Diet_Name, Diet_Info, UserID, name) VALUES (?, ?, ?, ?)", diet_name, diet_info, user_id, name)
end

def delete_diet(diet_id)
    db = connect_to_db
    db.execute("DELETE FROM diets WHERE Diet_ID = ?", diet_id)
end

def update_diet(diet_name, diet_info, name, diet_id)
    db = connect_to_db
    db.execute("UPDATE diets SET Diet_Name = ?, Diet_Info = ?, name = ? WHERE Diet_ID = ?", diet_name, diet_info, name, diet_id)
end

def delet_user(user_id)
    db = connect_to_db
    db.execute("DELETE FROM user WHERE ID = ?", user_id)
end

def update_user(name, admin, user_id)
    db = connect_to_db
    db.execute("UPDATE user SET name = ?, admin = ? WHERE ID = ?", name, admin, user_id)
end 