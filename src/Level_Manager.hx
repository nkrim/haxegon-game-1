import haxegon.*;
import Main;
import Level;

/* LEVEL_MANAGER
================ */
class Level_Manager {

	// Protected vars
	var levels:Array<Level>;
	var current_index:Int;

	// Constructor
	public function new(levels:Array<Level>) {
		this.levels = levels.copy();
		// Set current level to level 0
		this.current_index = 0;
	}

	/* Level Selection
	------------------ */
	public function get_level():Level {
		return this.levels[this.current_index];
	}

	public function select_level(game:Main, index:Int):Bool {
		if(index < 0 || index >= this.levels.length)
			return false;
		this.current_index = index;
		var selected_level = this.levels[index];
		return game.change_level(selected_level);
	}

	public function next_level(game:Main):Bool {
		return select_level(game, this.current_index+1);
	}
	public function prev_level(game:Main):Bool {
		return select_level(game, this.current_index-1);
	}

	/* Rendering
	------------ */
	public function draw_level_selector(game:Main, simulating:Bool) {
		// TEMPORARY POSITIONAL VALUES
		var x = 720;
		var y = 10;
		var width = 200;
		var height = 80;
		var padding = 6;
		var title_padding = 10;
		var level_icon_width = 20;
		var level_icon_height = 8;
		var cur_level_border_width = 2;
		var next_prev_height = 38;
		var next_prev_width = 40;
		var border_width = 3;
		// TEMPORARY COLOR VALUES
		var background_color = 0x6d6b7a;
		var outline_color = 0x52515c;
		var level_color = 0x222222;
		var cur_level_color = 0xcccccc;
		var completed_level_color = 0xcccccc;
		var button_focus_color = 0x878499;

		// Computed values
		var reset_x_value = x + border_width + padding;
		var max_level_x = x + width-border_width-padding-next_prev_width-level_icon_width;
		var current_x = reset_x_value;
		var current_y = y + border_width+title_padding+padding;

		// Draw box
		Gfx.fillbox(x, y, width, height, outline_color);
		Gfx.fillbox(x+border_width, y+border_width, width-2*border_width, height-2*border_width, background_color);

		// Draw Title
		Text.display(x+border_width+padding, y+7, 'Level Selection');

		// Draw next_prev buttons, AND HANDLE INTERACTION (TEMP)
		// -----------------------------------------------------
		var mx = Mouse.x;
		var my = Mouse.y;

		// Prev display, hover logic, and interaction
		var prev_x = x+width-border_width-next_prev_width+1;
		var prev_y = y+border_width-1;
		// Hover logic
		if(!simulating && Geom.inbox(mx, my, prev_x, prev_y, next_prev_width, next_prev_height)) {
			Gfx.fillbox(prev_x, prev_y, next_prev_width, next_prev_height, button_focus_color);
			// Click interaction
			if(Mouse.leftreleased())
				this.prev_level(game);
		}
		Gfx.drawbox(prev_x, prev_y, next_prev_width, next_prev_height, outline_color);
		Text.display(prev_x+7, prev_y+(next_prev_height/2)-4, 'Prev');

		// Next display, hover logic, and interaction
		var next_x = prev_x;
		var next_y = prev_y+next_prev_height;
		if(!simulating && Geom.inbox(mx, my, next_x, next_y, next_prev_width, next_prev_height)) {
			Gfx.fillbox(next_x, next_y, next_prev_width, next_prev_height, button_focus_color);
			// Click interactoin
			if(Mouse.leftreleased())
				this.next_level(game);
		}
		Gfx.drawbox(next_x, next_y, next_prev_width, next_prev_height, outline_color);
		Text.display(next_x+7, next_y+(next_prev_height/2)-4, 'Next');


		// Draw level icons
		// ----------------
		for(i in 0...levels.length) {
			var level_complete = levels[i].has_been_completed();
			var color = level_complete ? completed_level_color : level_color;
			// If current level, make with border
			if(this.current_index == i)
				Gfx.drawbox(current_x-cur_level_border_width, current_y-cur_level_border_width, 
					level_icon_width+2*cur_level_border_width, level_icon_height+2*cur_level_border_width, 
					cur_level_color);
			Gfx.fillbox(current_x, current_y, level_icon_width, level_icon_height, color);

			// Update positional values
			current_x += level_icon_width + padding;
			if(current_x > max_level_x) {
				current_x = reset_x_value;
				current_y += level_icon_height + padding;
			}
		}
	}
}