import haxegon.*;
import Main;
import Signal_Manager;
import Signal_Manager.Universal_Signal_Reciever;

/* INTERFACES 
============= */
interface Level {
	public function load_level(game:Main):Void;
	public function unload_level(game:Main):Void;
	public function draw_level(simulating:Bool):Void;
	public function is_succesful():Bool;
	public function restart_level():Void;
}

/* LEVEL SPRITE SHEET MAPPINGS */
@:enum
abstract Level_Sheet(Int) from Int to Int {
  	var pattern_orb_bg 		= 0;
  	var pattern_orb_color 	= 1;
  	var pattern_orb_x		= 2;
}

/* LEVEL GLOBALS
================ */
class Level_Globals {
	public static var level_sheet_name = "level_sheet";
	public static function load_level_spritesheet() {
		Gfx.loadtiles(level_sheet_name, 64, 64);
	}
}

/* PATTERN_LEVEL
================ */
class Pattern_Level implements Level implements Universal_Signal_Reciever {

	// Statics
	public static var required_repetitions = 10;

	// Protected vars
	var pattern:Array<Array<Int>>;
	var read_pattern:Array<Array<Bool>>;
	var succesful_repetitions:Int;
	// Computed vars
	var max_line_width:Int;

	// Constructor
	public function new(pattern:Array<Array<Int>>) {
		this.pattern = pattern;
		this.read_pattern = new Array<Array<Bool>>();
		this.succesful_repetitions = 0;
		// Compute max_line_width
		this.max_line_width = 0;
		for(line in pattern) {
			if(line.length > max_line_width)
				max_line_width = line.length;
		}
	}

	/* Level Implementation
	----------------------- */
	public function load_level(game:Main) {
		game.signal_manager.add_universal_reciever(this);
	}

	public function unload_level(game:Main) {
		game.signal_manager.remove_universal_reciever(this);
		restart_level();
	}

	public function is_succesful() {
		return succesful_repetitions >= required_repetitions;
	}

	public function restart_level() {
		read_pattern = new Array<Array<Bool>>();
		succesful_repetitions = 0;
	}

	/* Universal_Signal_Reciever Implementation
	--------------------------------- */
	public function recieve_all_signals(channels:Array<Int>, game:Main) {
		if(is_succesful())
			return;

		var current_index = -1;
		// If read_pattern matches pattern, go to next repetition and start a new read_pattern
		if(read_pattern_matches()) {
			succesful_repetitions++;
			read_pattern = new Array<Array<Bool>>();
			// Insert new parallel array for the first pattern_line, initialized to full false
			read_pattern.push([for (i in 0...pattern[0].length) false]);
			current_index = 0;
		}
		// Otherwise, if read_pattern is shorter than pattern, go on to the next line
		else if(read_pattern.length < pattern.length) {
			current_index = read_pattern.length;
			// Insert new parallel array for the current pattern_line, initialized to full false
			read_pattern.push([for (i in 0...pattern[current_index].length) false]);
		}
		// Otherwise, failed, just let it run
		else {
			return;
		}

		// Process incoming signals
		var pattern_line = pattern[current_index];
		var read_pattern_line = read_pattern[current_index];
		var num_valid_channels = 0;
		for(i in 0...pattern_line.length) {
			var current_channel = pattern_line[i];
			if(channels.indexOf(current_channel) >= 0) {
				read_pattern_line[i] = true;
				num_valid_channels++;
			}
		}
		// If num_valid_channels is less than channels.length, then there were extraneous channel signals
		// Mark this with an extra `false` at the end of the read_pattern_line
		if(num_valid_channels < channels.length) {
			read_pattern_line.push(false);
		}
	}

	/* Rendering
	------------ */
	public function draw_level(simulating:Bool) {
		// TEMPORARY POSITIONAL VALUES
		var x = 720;
		var y = 100;
		var padding = 20;
		var line_padding = 10;
		var orb_padding = 10;
		var orb_size = 32;
		var border_width = 3;
		// TEMPORARY COLOR VALUES
		var background_color = 0x6d6b7a;
		var outline_color = 0x52515c;
		var valid_color = 0x06aa00;
		var invalid_color = 0xf51515;

		// Draw backgroud
		var width = 2*padding + (2*orb_padding + orb_size)*(max_line_width+1);
		var height = 2*padding - line_padding + (line_padding + 2*orb_padding + orb_size)*pattern.length;
		Gfx.fillbox(x, y, width, height, outline_color);
		Gfx.fillbox(x+border_width, y+border_width, width-(2*border_width), height-(2*border_width), background_color);
	
		// Draw Title
		Text.display(x+padding, y+7, '$succesful_repetitions of $required_repetitions Iterations');

		// Draw orbs
		var line_width = (2*orb_padding + orb_size) * max_line_width;
		var line_height = 2*orb_padding + orb_size;
		var line_x = x + padding;
		var line_y = y + padding;
		for(i in 0...pattern.length) {
			// Draw line border
			var line_state = read_pattern_line_state(i);
			var box_color = line_state > 0 ? valid_color : (line_state < 0 ? invalid_color : outline_color);
			Gfx.drawbox(line_x, line_y, line_width, line_height, box_color);

			// Draw orbs
			var pattern_line = pattern[i];
			var read_pattern_line = i < read_pattern.length ? read_pattern[i] : null;
			var orb_x = line_x + orb_padding;
			var orb_y = line_y + orb_padding;
			for(i in 0...pattern_line.length) {
				Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_bg);
				Gfx.imagecolor = Signal_Manager.channels[pattern_line[i]];
				Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_color);
				Gfx.resetcolor();
				if(read_pattern_line != null && !read_pattern_line[i]) {
					Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_x);
				}
				
				// Advance orb_x to the next orb
				orb_x += 2*orb_padding + orb_size;
			}
			// Check if extra signals were sent
			if(read_pattern_line != null && read_pattern_line.length > pattern_line.length) {
				Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_bg);
				Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_color);
				Gfx.drawtile(orb_x, orb_y, Level_Globals.level_sheet_name, Level_Sheet.pattern_orb_x);
			}

			// Advance line_y coords to the next line
			line_y += 2*orb_padding + line_padding + orb_size;
		}
	}


	/* Helpers
	---------- */
	public function read_pattern_matches() {
		if(read_pattern.length != pattern.length)
			return false;
		for(line in read_pattern) {
			if(line.indexOf(false) >= 0)
				return false;
		}
		return true;
	}

	public function read_pattern_failed() {
		if(read_pattern.length > pattern.length)
			return true;
		for(line in read_pattern) {
			if(line.indexOf(false) >= 0)
				return true;
		}
		return false;
	}

	// Returns 1 if matching, -1 if failed, 0 if hasn't been read yet
	public function read_pattern_line_state(index:Int):Int {
		if(index >= read_pattern.length || index >= pattern.length)
			return 0;
		if(read_pattern[index].indexOf(false) >= 0)
			return -1;
		return 1;
	}
}
