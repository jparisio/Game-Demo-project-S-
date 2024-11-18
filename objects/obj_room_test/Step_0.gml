// Step Event
if (keyboard_check_pressed(vk_backspace)) {
    if (string_length(input_number) > 0) {
        input_number = string_delete(input_number, string_length(input_number), 1);
    }
}

for (var i = ord("0"); i <= ord("9"); i++) {
    if (keyboard_check_pressed(i)) {
        input_number += chr(i);
    }
}

if (keyboard_check_pressed(vk_enter)) {
    var room_index = real(input_number);
    if (room_exists(room_index)) {
        room_goto(room_index);
    } else {
        error_message = "Room does not exist!";
    }
}
