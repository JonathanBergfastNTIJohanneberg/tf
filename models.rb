module Models
    # Establishes connection to the database
    #
    # @return [SQLite3::Database] A database connection
    def connect_to_db()
        db = SQLite3::Database.new("db/ovning_urval.db")
        db.results_as_hash = true
        db
    end

    # Retrieves a specific diet and its associated user
    #
    # @param [Integer] id The ID of the diet
    # @return [Hash] The diet and its user details or nil if not found
    def get_diet(id)
        db = connect_to_db
        db.execute("SELECT diets.*, user.name AS user_name FROM diets JOIN user ON diets.UserID = user.ID WHERE Diet_ID = ?", id).first
    end

    # Retrieves all users
    #
    # @return [Array<Hash>] An array of user records
    def get_users()
        db = connect_to_db
        db.execute("SELECT * FROM user")
    end

    # Retrieves all diets and their associated users
    #
    # @return [Array<Hash>] An array of diet records with user details
    def get_diets()
        db = connect_to_db
        db.execute("SELECT diets.*, user.name AS user_name FROM diets JOIN user ON diets.UserID = user.ID")
    end

    # Retrieves a specific user's plan by plan ID
    #
    # @param [Integer] plan_id The ID of the plan
    # @return [Hash] The plan details or nil if not found
    def get_user_plan_by_id(plan_id)
        db = connect_to_db
        db.execute("SELECT * FROM plans WHERE ID = ?", plan_id).first
    end

    # Updates a specific plan with new details
    #
    # @param [Integer] plan_id The ID of the plan
    # @param [String] monday The details for Monday
    # @param [String] tuesday The details for Tuesday
    # @param [String] wednesday The details for Wednesday
    # @param [String] thursday The details for Thursday
    # @param [String] friday The details for Friday
    # @param [String] saturday The details for Saturday
    # @param [String] sunday The details for Sunday
    # @return [void]
    def update_plan(plan_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
        db = connect_to_db
        db.execute("UPDATE plans SET Monday = ?, Tuesday = ?, Wednesday = ?, Thursday = ?, Friday = ?, Saturday = ?, Sunday = ? WHERE ID = ?", monday, tuesday, wednesday, thursday, friday, saturday, sunday, plan_id)
    end

    # Records a like for a diet by a user
    #
    # @param [Integer] user_id The ID of the user
    # @param [Integer] diet_id The ID of the diet
    # @return [void]
    def like_diet(user_id, diet_id)
        db = connect_to_db
        db.execute("INSERT INTO UserLikedDiets (UserID, DietID) VALUES (?, ?)", [user_id, diet_id])
    end

    # Removes a like for a diet by a user
    #
    # @param [Integer] user_id The ID of the user
    # @param [Integer] diet_id The ID of the diet
    # @return [void]
    def unlike_diet(user_id, diet_id)
        db = connect_to_db
        db.execute("DELETE FROM UserLikedDiets WHERE UserID = ? AND DietID = ?", [user_id, diet_id])
    end

    # Checks if a diet is liked by a user
    #
    # @param [Integer] user_id The ID of the user
    # @param [Integer] diet_id The ID of the diet
    # @return [Boolean] True if the diet is liked by the user, false otherwise
    def check_like(user_id, diet_id)
        db = connect_to_db
        result = db.execute("SELECT * FROM UserLikedDiets WHERE UserID = ? AND DietID = ?", [user_id, diet_id])
        !result.empty?
    end

    # Counts the number of likes for a specific diet
    #
    # @param [Integer] diet_id The ID of the diet
    # @return [Integer] The count of likes
    def self.count_likes(diet_id)
        db = connect_to_db
        result = db.execute("SELECT COUNT(UserID) as count FROM UserLikedDiets WHERE DietID = ?", [diet_id])
        result.first['count'] || 0
    end

    # Checks if a user has admin privileges
    #
    # @param [Integer] user_id The ID of the user
    # @return [Boolean] True if the user is an admin, false otherwise
    def user_is_admin?(user_id)
        db = connect_to_db
        result = db.execute("SELECT admin FROM user WHERE ID = ?", user_id).first
        result && result['admin'] == 1
    end

    # Retrieves user details by username
    #
    # @param [String] username The username to search
    # @return [Hash] The user details or nil if not found
    def get_results(username)
        db = connect_to_db
        db.execute("SELECT * FROM user WHERE name = ?", username).first
    end

    # Registers a new user
    #
    # @param [String] username The username
    # @param [String] password_digest The password hash
    # @param [String] email The email address
    # @return [void]
    def get_register_form(username, password_digest, email)
        db = connect_to_db
        db.execute("INSERT INTO user (name, password, email, admin) VALUES (?, ?, ?, 0)", username, password_digest, email)
    end

    # Retrieves a user's plan
    #
    # @param [Integer] user_id The ID of the user
    # @return [Hash] The plan details or nil if not found
    def get_user_plan(user_id)
        db = connect_to_db
        plan = db.execute("SELECT * FROM plans WHERE UserID = ?", user_id).first
        return plan
    end

    # Saves a new plan for a user
    #
    # @param [Integer] user_id The ID of the user
    # @param [String] monday The details for Monday
    # @param [String] tuesday The details for Tuesday
    # @param [String] wednesday The details for Wednesday
    # @param [String] thursday The details for Thursday
    # @param [String] friday The details for Friday
    # @param [String] saturday The details for Saturday
    # @param [String] sunday The details for Sunday
    # @return [void]
    def save_plans(user_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
        db = connect_to_db
        db.execute("INSERT INTO plans (UserID, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", user_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
    end

    # Saves a new diet for a user
    #
    # @param [String] diet_name The name of the diet
    # @param [String] diet_info The information about the diet
    # @param [Integer] user_id The ID of the user
    # @param [String] name The name associated with the diet
    # @return [void]
    def save_diet(diet_name, diet_info, user_id, name)
        db = connect_to_db
        db.execute("INSERT INTO diets (Diet_Name, Diet_Info, UserID, name) VALUES (?, ?, ?, ?)", diet_name, diet_info, user_id, name)
    end

    # Deletes a diet from the database
    #
    # @param [Integer] diet_id The ID of the diet
    # @return [void]
    def delete_diet(diet_id)
        db = connect_to_db
        db.execute("DELETE FROM diets WHERE Diet_ID = ?", diet_id)
    end

    # Updates the details of an existing diet
    #
    # @param [String] diet_name The new name of the diet
    # @param [String] diet_info The new information about the diet
    # @param [String] name The new name associated with the diet
    # @param [Integer] diet_id The ID of the diet
    # @return [void]
    def update_diet(diet_name, diet_info, name, diet_id)
        db = connect_to_db
        db.execute("UPDATE diets SET Diet_Name = ?, Diet_Info = ?, name = ? WHERE Diet_ID = ?", diet_name, diet_info, name, diet_id)
    end

    # Deletes a user from the database
    #
    # @param [Integer] user_id The ID of the user
    # @return [void]
    def delet_user(user_id)
        db = connect_to_db
        db.execute("DELETE FROM user WHERE ID = ?", user_id)
    end

    # Updates user information
    #
    # @param [String] name The new name of the user
    # @param [Boolean] admin Whether the user has admin rights
    # @param [Integer] user_id The ID of the user
    # @return [void]
    def update_user(name, admin, user_id)
        db = connect_to_db
        db.execute("UPDATE user SET name = ?, admin = ? WHERE ID = ?", name, admin, user_id)
    end
end