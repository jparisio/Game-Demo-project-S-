fsm.step();

// Manage cooldown
if (cooldown && alarm[0] == -1) {
    alarm[0] = 120; // Set the cooldown duration
}

