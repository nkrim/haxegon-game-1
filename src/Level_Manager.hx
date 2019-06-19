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
	public function draw_level_selector(simulating:Bool) {
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
		var border_width = 3;
		// TEMPORARY COLOR VALUES
		var background_color = 0x6d6b7a;
		var outline_color = 0x52515c;
		var level_color = 0x222222;
		var cur_level_color = 0xcccccc;
		var completed_level_color = 0xcccccc;

		// Computed values
		var reset_x_value = x + border_width + padding;
		var max_level_x = x + width-border_width-padding-level_icon_width;
		var current_x = reset_x_value;
		var current_y = y + border_width+title_padding+padding;

		// Draw box
		Gfx.fillbox(x, y, width, height, outline_color);
		Gfx.fillbox(x+border_width, y+border_width, width-2*border_width, height-2*border_width, background_color);

		// Draw Title
		Text.display(x+border_width+padding, y+7, 'Level Selection');

		// Draw level icons
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