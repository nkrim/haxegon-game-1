import haxegon.*;
import Wire.*;
import Wire.Wire_Status.*;


/* ENUM CLASSES */
@:enum
abstract Direction(Int) from Int to Int {
	var NODIR 	= 0;
	var UP 	 	= 1;
	var DOWN 	= 2;
	var LEFT	= 3;
	var RIGHT	= 4;
}


/* TYPEDEFS */
typedef Cell = {
	r : Int,
	c : Int,
}
typedef Point = {
	x : Int,
	y : Int,
}



class Main {
	function init(){
	  	Text.font = "Kankin";
	  	Text.size = 32;
	  	Gfx.clearcolor = 0x222222;

	  	wire_grid = [for (r in 0...grid_height) [for (c in 0...grid_width) Wire.init_wire_module()]];

	  	// Init sheet loading
	  	Wire.load_wire_spritesheet();
	}
  
	function update() {
	  	Text.display(0, 0, "Hello, Sailor!");

	  	handle_wire_drawing();
	  	draw_wire_grid();
	}

	var wire_grid : Array<Array<Wire.Wire_Module>>;

	var grid_width = 8;
  	var grid_height = 8;
  	var grid_x = 100;
  	var grid_y = 100;

  	public static var module_side_length = 64;
  	public static var half_module_length = 32;

  	var outline_color = 0x52515c;



  	/* INTERACTION
  	============== */
  	public static function general_wire_hover_status(x:Int, y:Int) {
		var mx = Mouse.x - x;
		var my = Mouse.y - y;

		if(mx < 0 || mx >= module_side_length || my < 0 || my >= module_side_length)
			return NODIR;

		var upper_right = mx >= my;
		var lower_right = mx >= (module_side_length - my);

		if(upper_right) {
			if(lower_right)
				return RIGHT;
			return UP;
		}
		if(lower_right)
			return DOWN;
		return LEFT;
	}

	public static function general_wire_hover_status_with_tolerance(x:Int, y:Int, last_dir:Direction, tolerance:Int=6) {
		var new_dir = general_wire_hover_status(x, y);
		if(new_dir == NODIR)
			return NODIR;
		else if(new_dir == last_dir)
			return last_dir;

		var mx = Mouse.x - x;
		var my = Mouse.y - y;

		if(Geom.inbox(mx, my, half_module_length-tolerance, half_module_length-tolerance, tolerance*2, tolerance*2))
			return last_dir;
		return new_dir;
	}

  	function get_hover_cell():Cell {
  		var mx = Mouse.x - grid_x;
  		var my = Mouse.y - grid_y;

  		if(mx < 0 || my < 0)
  			return null;

  		var r = Std.int(my / module_side_length);
  		var c = Std.int(mx / module_side_length);

  		if(r >= grid_height || c >= grid_width)
  			return null;

  		return { r:r, c:c }; 
  	}

  	/* WIRE DRAWING RULES
  	---------------------
  	- If drawing forward, follow through, despite wire status
	- As soon as backtracking, start deleting
	- When starting on an enabled wire, assume forward unless going directly to an enabled wire
	- If went to a non-adjacent cell, end drawing_mode
	- When drag-drawing, resolve after change 
	- When cell changes, the former backwards-path is irrelevant, as long as still backtracking on enabled wire
	- When in backwards mode, each deletion resets entry dir
	- If went to an adjacent cell, but skipped a dir, try and smartly decide what should ahve been done for that dir
		- ^^^^ IMPLEMENT THIS LAST
	*/

	var drawing_wires_initial_click = false;
  	var drawing_wires = false;
  	var drawing_backwards = false;
  	var drawing_last_cell:Cell = null;
  	var drawing_entry_dir = NODIR; // can be NODIR while drawing
  	var drawing_last_dir = NODIR;

	function handle_wire_drawing() {
		var hover_cell = get_hover_cell();

		// Reset when exiting grid
		if(hover_cell == null) {
			// Handle when intial click position never changed, but dragged off grid
			if(drawing_wires_initial_click) {
				var wm = get_wire_from_cell(drawing_last_cell);
				// If it was disabled, enable it
				if(get_wire_status(wm, drawing_last_dir) == disabled)
					set_wire_status(wm, drawing_last_dir, off);
				// Otherwise, if backwards, disable
				else if(drawing_backwards)
					set_wire_status(wm, drawing_last_dir, disabled);
			}
			if(drawing_wires) {
				drawing_wires_initial_click = false;
				drawing_wires = false;
			}
		}

		// Initiate drawing wires on left click
		else if(!drawing_wires && Mouse.leftclick()) {
			var cell_point = get_cell_point(hover_cell);
			var hover_dir = general_wire_hover_status(cell_point.x, cell_point.y);
			// If hover status failed, pretend nothing happened
		  	if(hover_dir == NODIR)
		  		return;
		  	// If the selected wire is enabled, don't use hover_dir as entry_dir
		  	var wm = get_wire_from_cell(hover_cell);
		  	drawing_last_dir = hover_dir;	

			drawing_wires_initial_click = true;
		  	drawing_wires = true;
		  	drawing_last_cell = hover_cell; 	
		  	// If the selected wire is enabled, start by going backwards w/ no entry dir
		  	var wm = get_wire_from_cell(hover_cell);
		  	if(get_wire_status(wm, hover_dir) != disabled) {
		  		drawing_backwards = true;
		  		drawing_entry_dir = NODIR;
		  	}
		  	else {
		  		drawing_backwards = false;
		  		drawing_entry_dir = hover_dir;
		  	} 
		}

		// Handle drawing
		else if(drawing_wires) {
			// If cells are equal, try and handle dir change
			if(equal_cells(hover_cell, drawing_last_cell)) {
				var cell_point = get_cell_point(hover_cell);
				var new_dir = general_wire_hover_status_with_tolerance(cell_point.x, cell_point.y, drawing_last_dir);
				// If new_dir is NODIR then break out of drawing_mode
				if(new_dir == NODIR) {
					if(drawing_wires_initial_click) drawing_wires_initial_click = false;
					Mouse.leftforcerelease();
				}
				else {
					var wm = get_wire_from_cell(hover_cell);
					handle_in_cell_wire_drawing_change(wm, drawing_last_dir, new_dir);
				}
			}

			// Handle cell change
			else {
				if(drawing_wires_initial_click) drawing_wires_initial_click = false;
				// Determine new_dir
				var cell_point = get_cell_point(hover_cell);
				var new_dir = general_wire_hover_status_with_tolerance(cell_point.x, cell_point.y, drawing_last_dir);
				// If new_dir is NODIR then break out of drawing_mode
				if(new_dir == NODIR) {
					Mouse.leftforcerelease();
				}
				else {
					// Grab useful vars
					var last_wm = get_wire_from_cell(drawing_last_cell);
					var new_wm = get_wire_from_cell(hover_cell);
					var cell_adj_dir = cell_adjacency_dir(drawing_last_cell, hover_cell);
					// If skipped a cell, CURRENTLY WE EXIT DRAWING MODE BY FORCE RELEASING LEFTCLICK
					// LATER WE WILL SMART, DECIDE WHAT TO DO IF IT IS EASY ENOUGH TO EVALUATE INTENDED PATH
					if(cell_adj_dir == NODIR) {
						Mouse.leftforcerelease();
					}
					else {
						// If last_dir is not adjacent to the current cell, work through last_cell changes
						if(cell_adj_dir != drawing_last_dir) {
							handle_in_cell_wire_drawing_change(last_wm, drawing_last_dir, cell_adj_dir);
						}
						// If new_dir is not the opposite of adj_dir, skipped a wire, perform change on intermediate, then work in-cell to cur
						var final_dir = NODIR;
						if(opposite_dir(cell_adj_dir) != new_dir) {
							final_dir = new_dir;
							new_dir = opposite_dir(drawing_last_dir);
						}
						// Grab more useful vars
						var last_dir_status = get_wire_status(last_wm, drawing_last_dir);
						var new_dir_status = get_wire_status(new_wm, new_dir);
						var last_enabled = last_dir_status != disabled;
						var new_enabled = new_dir_status != disabled;
						// If backwards, disable last dir
						if(drawing_backwards) {
							set_wire_status(last_wm, drawing_last_dir, disabled);
							// If new is enabled, set entry_dir to NODIR
							if(new_enabled)
								drawing_entry_dir = NODIR;
							// Otherwise, change to forward and set new entry_dir
							else {
								drawing_backwards = false;
								drawing_entry_dir = new_dir;
							}
						}
						// If last dir was entry_dir and new dir is enabled, enter backwards mode and delete last_dir if enabled
						else if(new_enabled && drawing_last_dir == drawing_entry_dir) {
							drawing_backwards = true;
							if(last_enabled)
								set_wire_status(last_wm, drawing_last_dir, disabled);
							// Set entry_dir to NODIR
							drawing_entry_dir = NODIR;
						}
						// (Else in forward mode)
						else {
							// If last dir was disabled, enable it
							if(!last_enabled) {
								set_wire_status(last_wm, drawing_last_dir, off);
							}
							// Set new entry_dir
							drawing_entry_dir = new_dir;
							// Set last_dir to new_dir
							drawing_last_dir = new_dir;
						}

						// Set last_cell to hover_cell
						drawing_last_cell = hover_cell;
						// If final_dir, then do in-cell transfer
						if(final_dir != NODIR)
							handle_in_cell_wire_drawing_change(new_wm, new_dir, final_dir);
						else
							drawing_last_dir = new_dir;
					}
				}
			}
		}

		// HANDLE MOUSE RELEASE
		if(drawing_wires && !Mouse.leftheld()) {
			trace("Mouse release");
			var wm = get_wire_from_cell(drawing_last_cell);
			// If still intial click position, toggle current wire
			if(drawing_wires_initial_click) {
				set_wire_status(wm, drawing_last_dir, get_wire_status(wm, drawing_last_dir) == disabled ? off : disabled);
				drawing_wires_initial_click = false;
			}
			// Otherwise, if hovered wire is disabled and there is an entry dir, enable it
			else if(drawing_entry_dir != NODIR &&  get_wire_status(wm, drawing_last_dir) == disabled) {
				set_wire_status(wm, drawing_last_dir, off);
			}
			drawing_wires = false;
		}

		// HANDLE HOVERING
		if(drawing_wires && drawing_last_cell != null && drawing_last_dir != NODIR) {
			var wm = get_wire_from_cell(drawing_last_cell);
			wm.hovering = drawing_last_dir;
		}
		else if(hover_cell != null) {
			var wm = get_wire_from_cell(hover_cell);
			var cell_point = get_cell_point(hover_cell);
			wm.hovering = general_wire_hover_status(cell_point.x, cell_point.y);
		}
	}

	function handle_in_cell_wire_drawing_change(wm:Wire.Wire_Module, last_dir:Direction, new_dir:Direction) {
		// Handle dir change
		if(new_dir != last_dir) {
			// Reset initial click var if set
			if(drawing_wires_initial_click) drawing_wires_initial_click = false;
			// Grab useful vars
			var last_dir_status = get_wire_status(wm, last_dir);
			var new_dir_status = get_wire_status(wm, new_dir);
			var last_enabled = last_dir_status != disabled;
			var new_enabled = new_dir_status != disabled;
			// Handle leaving entry_dir
			if(last_dir == drawing_entry_dir) {
				// If backwards while leaving entry-dir, in-cell, enter forward mode
				if(drawing_backwards) {
					drawing_backwards = false;
				}
				// If forward and last_dir was disabled, enable it
				else if(!last_enabled) {
					set_wire_status(wm, last_dir, off);
				}
			}
			// If moving from non-entry dir to entry dir and both are enabled, enter backwards mode and delete
			else if(new_dir == drawing_entry_dir && last_enabled) {
				drawing_backwards = true;
				set_wire_status(wm, last_dir, disabled);
				// Set new_dir to entry_dir
				drawing_entry_dir = new_dir;
			}
			// If going backwards with no entry dir, disable last_dir
			else if(drawing_backwards && drawing_entry_dir == NODIR) {
				set_wire_status(wm, last_dir, disabled);
				// If new_dir is disabled, change to forward mode
				if(!new_enabled)
					drawing_backwards = false;
				// Otherwise set new_dir to entry_dir
				else 
					drawing_entry_dir = new_dir;
			}
			// Otherwise, just moving around current_cell wires, and no action will be taken

			// Set last_dir to new_dir
			drawing_last_dir = new_dir;
		}
		// Otherwise, no change at all
	} 


  	/* RENDERING 
  	============ */
  	function draw_wire_grid() {
  		// Render outline for bottom and right sides
  		Gfx.drawline(	grid_x+1 + (module_side_length*grid_width), grid_y+1,
  					 	grid_x+1 + (module_side_length*grid_width), grid_y+1 + (module_side_length*grid_height ),
  					 	outline_color);
  		Gfx.drawline(	grid_x+1, 									grid_y+1 + (module_side_length*grid_height),
  						grid_x+1 + (module_side_length*grid_width), grid_y+1 + (module_side_length*grid_height),
  						outline_color);
  		// Render in reverse order to preserve overlapping pixels
  		var r = grid_height;
  		while((--r) >= 0) {
  			var c = grid_width;
  			while((--c) >= 0) {
  				var wm = wire_grid[r][c];
	  			Wire.draw_wire_module(grid_x + c*module_side_length, grid_y + r*module_side_length, wm, false);
  			}
  		}
  	}



  	/* CELL HELPERS
 	=============== */
 	public function get_wire_from_cell(c:Cell) {
 		return wire_grid[c.r][c.c];
 	}

 	public function get_cell_point(c:Cell) {
 		return { x: grid_x + c.c*module_side_length, y: grid_y + c.r*module_side_length };
 	} 

 	public static function cell_adjacency_dir(a:Cell, b:Cell) {
 		if(a.r == b.r) {
 			if(a.c+1 == b.c) 
 				return RIGHT;
 			else if(a.c-1 == b.c)
 				return LEFT;
 		}
 		else if(a.c == b.c) {
 			if(a.r+1 == b.r)
 				return DOWN;
 			else if(a.r-1 == b.r)
 				return UP;
 		}
 		return NODIR;
 	}

 	public static function equal_cells(a:Cell, b:Cell) {
 		return a.r == b.r && a.c == b.c;
 	}
 	
 	public static function opposite_dir(dir:Direction) {
 		return switch(dir) {
 			case UP: DOWN;
 			case DOWN: UP;
 			case LEFT: RIGHT;
 			case RIGHT: LEFT;
 			default: NODIR;
 		}
 	}
}