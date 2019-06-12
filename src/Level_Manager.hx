import Main;
import Level;

/* LEVEL_MANAGER
================ */
class Level_Manager {

	// Protected vars
	var levels:Array<Level>;
	var level_completion:Array<Bool>;
	var current_index:Int;

	// Constructor
	public function new(levels:Array<Level>) {
		this.levels = levels.copy();
		// Init array of equal size to `levels` but filled with `false` as default value
		this.level_completion = [for (i in 0...levels.length) false];
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

	}
}