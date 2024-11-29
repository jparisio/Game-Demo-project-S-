// Function to load the game data
function load_game_data() {

	
    // Check if the save file exists
	if (!file_exists("save_game_data.json")) {
		show_debug_message("shit doesnt exist");
	    // If the file doesn't exist, create it with default data
	    create_default_save_file("save_game_data.json");
	}
	
	// Read the JSON file
    var file = file_text_open_read("save_game_data.json");
    var json_data = "";
    
    // Read the entire file into a string
    while (!file_text_eof(file)) {
        json_data += file_text_read_string(file);
        file_text_readln(file); // Move to the next line
    }
    
    // Close the file
    file_text_close(file);
    
    // Parse the JSON data
    var data = json_parse(json_data);
    
    // Check if data was successfully parsed
    if (data != undefined) {
		return data;
    }
}


// Function to create a default save file with initial data
function create_default_save_file(file_name) {
    // Create a new file and open it for writing
    var file = file_text_open_write(file_name);
    
    // Define default data in a structure
    var default_data = {
        "room": "Room01",
    };
    
    // Convert the structure to a JSON string
    var json_data = json_stringify(default_data);
    
    // Write the JSON string to the file
    file_text_write_string(file, json_data);
    
    // Close the file
    file_text_close(file);
    
    show_debug_message("New save file created: " + file_name);
}


// Function to save the game data
function save_game() {
    var file_name = "save_game_data.json";
    
    var current_room = room_get_name(room);  // Get the name of the current room
    
    var save_data = {
        "room": current_room,
    };
   
    var json_data = json_stringify(save_data);
    var file = file_text_open_write(file_name);
    file_text_write_string(file, json_data);
    
    // Close the file
    file_text_close(file);
    
    // Optional: Show a debug message indicating the save was successful
    show_debug_message("Game saved: " + file_name);
}


