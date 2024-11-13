draw_y += sin(current_time / 80) * 0.5;
end_alpha = lerp(end_alpha, alpha, .2);
draw_sprite_ext(sprite_index, image_index, draw_x, draw_y, image_xscale, image_yscale, 0, c_white, end_alpha);




