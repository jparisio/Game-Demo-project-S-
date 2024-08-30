
if(create_at != noone){


if !sprayed {
	//to make it more like kzero, the way he does it is have an initial blood spray, 
	//then every frame creates some blood opposite of the direction the character is sliding at slighlty cahnging tis direction
	//then for the final bit, face the blood upwards and move slkightly left and right.  Ill do this eventually
	repeat(50) create_blood(facing, create_at.x -10, create_at .y-40)
	sprayed = true;
}


}