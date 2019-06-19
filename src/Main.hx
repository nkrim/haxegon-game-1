import haxegon.*;
import Wire_Module.*;
import Wire_Module.Module_Sheet;
import Wire_Module.Wire_Status.*;
import Tooltip;
import Signal_Manager;
// Modules
import Modules.Power_Module;
import Modules.Bridge_Module;
import Modules.Diode_Module;
import Modules.Emittor_Module;
import Modules.Reciever_Module;
// Augmentations
import Augmentation.Toggle_Augmentation;
import Augmentation.Rotator_Augmentation;
// Levels
import Level;
import Level.Level_Globals;
import Level.Pattern_Level;
import Level_Manager;


/* ENUM CLASSES */
@:enum
abstract Direction(Int) from Int to Int {
	var NODIR 	= 0;
	var UP 	 	= 1;
	var DOWN 	= 2;
	var LEFT	= 3;
	var RIGHT	= 4;
}
@:enum
abstract Tool(Int) from Int to Int {
	var wire 		= Module_Sheet.center_shadow;
	var power 		= Module_Sheet.power_off;
	var or_diode 	= Module_Sheet.diode_off;
	var and_diode 	= Module_Sheet.diode_and_off;
	var emittor 	= Module_Sheet.emittor_base_display;
	var reciever 	= Module_Sheet.reciever_base_display;
	var bridge 		= Module_Sheet.bridge_off;
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
typedef Tool_Data = {
	name: String,
	tool: Tool,
}



class Main {
	function init(){
	  	Text.size = 8;
	  	Gfx.clearcolor = 0x222222;

	  	// Init wire_grid with a fresh board
	  	reset_board();
	  	// wire_grid = [for (r in 0...grid_height) [for (c in 0...grid_width) new Wire_Module({r:r,c:c})]];

	  	level_manager = new Level_Manager(generate_levels());
	  	level = level_manager.get_level();
	  	signal_manager = new Signal_Manager();

	  	level.load_level(this);

	  	// Init sheet loading
	  	Wire_Module.load_module_spritesheet();
	  	Tooltip.load_tooltip_spritesheet();
	  	Level_Globals.load_level_spritesheet();

	  	// DEBUG VALUES
	  	Core.showstats = true;
	}
  
	function update() {
	  	Gui.window("Simulation controls", grid_x, 10);
	  	if(!simulating) {
	  		if(Gui.button("Play")) {
	  			play();
	  		}
	  		Gui.nextrow();
	  		if(Gui.button("Tick")) {
	  			play();
	  			pause();
	  		}
	  		Gui.shift();
	  		if(Gui.button("Reset")) {
	  			reset();
	  		}
	  	}
	  	else {
	  		if(this.playing) {
	  			if(Gui.button("Pause")) {
	  				pause();
	  			}
	  		}
	  		else {
	  			if(Gui.button("Resume")) {
	  				resume();
	  			}
	  		}

	  		Gui.shift();
	  		if(Gui.button("Stop")) {
	  			stop();
	  		}

	  		Gui.nextrow();
	  		if(!this.playing && Gui.button("Tick")) {
	  			tick();
	  		}
	  	}
	  	Gui.end();

	  	// After handling the UI Controls, if a tick should be performed, do so
	  	if(should_perform_play_tick()) {
	  		tick();
	  	}

	  	if(!simulating) {
	  		handle_wire_drawing_and_hovering();
	  	}

	  	handle_tooltip_interaction();

	  	level_manager.draw_level_selector(simulating);
	  	if(level != null)
	  		level.draw_level(simulating);
	  	draw_wire_grid();
	  	handle_and_draw_toolbar(simulating);

	  	tooltip.draw_tooltip();
	}

	/* GAME PROPERTIES
	================== */
	var wire_grid : Array<Array<Wire_Module>>;

	var grid_width = 8;
  	var grid_height = 8;
  	var grid_x = 200;
  	var grid_y = 100;

  	var tick_rate = 0.5;
  	var time_of_last_tick = -1.0;
  	var playing = false;

  	public var level : Level;
  	public var level_manager : Level_Manager;
  	public var signal_manager : Signal_Manager;

  	var tool_x = 100;
  	var tool_y = 100;
  	var tool_cols = 2;
  	var tool_side_length = 41;
  	var tools:Array<Tool_Data> = [
  		{ name: "Wire", tool: Tool.wire, },
		{ name: "Power", tool: Tool.power, },
		{ name: "OR", tool: Tool.or_diode,	},
		{ name: "AND", tool: Tool.and_diode, },
		{ name: "Emittor", tool: Tool.emittor, },
		{ name: "Reciever", tool: Tool.reciever, },
		{ name: "Bridge", tool: Tool.bridge, },
	];

  	var tooltip = new Tooltip();

  	var simulating = false;
  	var resolution_tick = true; // Whether or not this is a resolution_tick or a power_tick

  	public static var module_side_length = 64;
  	public static var half_module_length = 32;

  	var tile_background_color = 0x6d6b7a;
  	var tile_focus_color = 0x878499;
  	var outline_color = 0x52515c;


  	/* LEVEL GENERATION
  	=================== */
  	function generate_levels():Array<Level> {
  		var levels = new Array<Level>();
  		// Level 1
  		levels.push(new Pattern_Level([[0],[1],[2],[3]]));
  		// Level 2
  		levels.push(new Pattern_Level([[0,1],[2,3],[0,2],[1,3]]));
  		
  		// Return
  		return levels;
  	}


  	/* MECHANICS
  	============ */
  	function play() {
  		Mouse.leftforcerelease();
	  	Mouse.rightforcerelease();
  		this.playing = true;
  		this.simulating = true;
  		this.resolution_tick = true;

  		tick();
  		time_of_last_tick = Core.time;
  	}
  	function pause() {
  		this.playing = false;
  	}
  	function resume() {
  		if(this.simulating) {
  			this.playing = true;
  			tick();
  		}
  	}
  	function stop() {
		this.playing = false;
		this.simulating = false;
		restart_modules_and_augmentations();
		this.signal_manager.clear_queued_signals();
		this.level.restart_level();
  	}
  	function reset() {
  		level.unload_level(this);
		signal_manager.reset_signal_manager();
		reset_board();
		level.load_level(this);
  	}

  	function should_perform_play_tick() {
  		return simulating && playing && Core.time - time_of_last_tick >= tick_rate;
  	}

  	function tick() {
  		// Resolution tick, just perform augmentation actions based on channel inputs
  		if(this.resolution_tick) {
  			// Restart all modules first
  			for(row in this.wire_grid) {
  				for(wm in row) {
  					wm.restart_module();
  				}
  			}
  			// Continue resolving on next tick if any signals resolved
  			this.resolution_tick = this.signal_manager.resolve_signals_once(this);
  		}
  		// Power tick, spread power and do module evalutions
  		if(!this.resolution_tick) {
  			for(row in this.wire_grid) {
  				for(wm in row) {
  					wm.start_power_tick(this);
  				}
  			}
  			this.resolution_tick = true;
  		}
  		
  		// Perform universal signal resolutions
  		this.signal_manager.resolve_universal_signals_once(this);

  		// Set time_of_last_tick
  		time_of_last_tick = Core.time;
  	}

  	function restart_modules() {
  		for(row in wire_grid) {
			for(wm in row) {
				wm.restart_module();
			}
		}
  	}
  	function restart_modules_and_augmentations() {
  		for(row in wire_grid) {
			for(wm in row) {
				wm.restart_module();
				// Reset augmentaitons
				if(wm.toggle_aug != null) 
					wm.toggle_aug.reset();
				if(wm.rotator_aug != null)
					wm.rotator_aug.reset(this);
			}
		}
  	}
  	function reset_board() {
  		this.wire_grid = [for (r in 0...grid_height) [for (c in 0...grid_width) new Wire_Module({r:r,c:c})]];
  	}

  	public function change_level(new_level:Level):Bool {
  		if(new_level == null)
  			return false;
  		this.level.unload_level(this);
		signal_manager.reset_signal_manager();
		reset_board();
		// Set new level
		this.level = new_level;
		this.level.load_level(this);
		return true;
  	}

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

  	// BASIC TOOLTIP INTERACTION
  	function handle_tooltip_interaction() {
  		// If simulating, make sure to quit out of tooltip if it is currently active, otherwise exit
  		if(simulating) {
  			if(tooltip.is_showing())
  				tooltip.set_module(null);
  			return;
  		}

  		var hover_cell = get_hover_cell();
  		// If right-click on a valid tile, open up tooltip for that tile 
  		if(Mouse.rightreleased()) {
  			if(hover_cell != null) {
  				var module = get_module_from_cell(hover_cell);
  				tooltip.set_module(module);
  				var cell_point = get_cell_point(hover_cell);
  				tooltip.set_position(cell_point.x+40, cell_point.y+40);
  			}
  		}
  		// If left click down or up outside of tooltipl, close it
  		else if((Mouse.leftclick() || Mouse.leftreleased()) && !tooltip.hovering()) {
  			tooltip.set_module(null);
  		}

  		if(tooltip.is_showing()) {
  			tooltip.handle_internal_interaction(this);
  		}
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

	/* OTHER POTENTIAL WIRE DRAWING RULES
	-------------------------------------
	- Most likely alternative, is to just decide whether or not creation mode or delete mode based on starting wire
	  and then axis-locking it. Pros: more accurate and intentional; Cons: more clicks
	*/

	var drawing_wires_initial_click = false;
  	var drawing_wires = false;
  	var drawing_backwards = false;
  	var drawing_last_cell:Cell = null;
  	var drawing_entry_dir = NODIR; // can be NODIR while drawing
  	var drawing_last_dir = NODIR;

	function handle_wire_drawing_and_hovering() {
		// If tooltip is showing, outline the tooltipped module, then exit
		if(tooltip.is_showing()) {
			tooltip.get_module().outline = true;
			return;
		}

		var hover_cell = get_hover_cell();

		// Reset when exiting grid
		if(hover_cell == null) {
			// Handle when intial click position never changed, but dragged off grid
			if(drawing_wires) {
				var wm = get_module_from_cell(drawing_last_cell);
				// If it was disabled, enable it
				if(wm.get_wire_status(drawing_last_dir) == disabled)
					wm.set_wire_status(drawing_last_dir, off);
				// Otherwise, if backwards, disable
				else if(drawing_backwards)
					wm.set_wire_status(drawing_last_dir, disabled);
				// Reset drawing_wires and initial_click vars
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
		  	var wm = get_module_from_cell(hover_cell);
		  	drawing_last_dir = hover_dir;	

			drawing_wires_initial_click = true;
		  	drawing_wires = true;
		  	drawing_last_cell = hover_cell; 	
		  	// If the selected wire is enabled, start by going backwards w/ no entry dir
		  	var wm = get_module_from_cell(hover_cell);
		  	if(wm.get_wire_status(hover_dir) != disabled) {
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
					var wm = get_module_from_cell(hover_cell);
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
					var last_wm = get_module_from_cell(drawing_last_cell);
					var new_wm = get_module_from_cell(hover_cell);
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
						var last_dir_status = last_wm.get_wire_status(drawing_last_dir);
						var new_dir_status = new_wm.get_wire_status(new_dir);
						var last_enabled = last_dir_status != disabled;
						var new_enabled = new_dir_status != disabled;
						// If backwards, disable last dir
						if(drawing_backwards) {
							last_wm.set_wire_status(drawing_last_dir, disabled);
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
								last_wm.set_wire_status(drawing_last_dir, disabled);
							// Set entry_dir to NODIR
							drawing_entry_dir = NODIR;
						}
						// (Else in forward mode)
						else {
							// If last dir was disabled, enable it
							if(!last_enabled) {
								last_wm.set_wire_status(drawing_last_dir, off);
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
			var wm = get_module_from_cell(drawing_last_cell);
			// If still intial click position, toggle current wire
			if(drawing_wires_initial_click) {
				wm.set_wire_status(drawing_last_dir, wm.get_wire_status(drawing_last_dir) == disabled ? off : disabled);
				drawing_wires_initial_click = false;
			}
			// Otherwise, if hovered wire is disabled and there is an entry dir, enable it
			else if(drawing_entry_dir != NODIR &&  wm.get_wire_status(drawing_last_dir) == disabled) {
				wm.set_wire_status(drawing_last_dir, off);
			}
			// Otherwise, if backwards drawing and on enabled wire, delete it
			else if(drawing_backwards && wm.get_wire_status(drawing_last_dir) != disabled) {
				wm.set_wire_status(drawing_last_dir, disabled);
			}
			drawing_wires = false;
		}

		// HANDLE HOVERING
		if(!holding_tool) {
			if(drawing_wires && drawing_last_cell != null && drawing_last_dir != NODIR) {
				var wm = get_module_from_cell(drawing_last_cell);
				wm.hovering = drawing_last_dir;
				wm.outline = true;
			}
			else if(hover_cell != null) {
				var wm = get_module_from_cell(hover_cell);
				var cell_point = get_cell_point(hover_cell);
				wm.hovering = general_wire_hover_status(cell_point.x, cell_point.y);
				wm.outline = true;
			}
		}
		else if(hover_cell != null){
			var wm = get_module_from_cell(hover_cell);
			var cell_point = get_cell_point(hover_cell);
			wm.outline = true;
		}
	}

	function handle_in_cell_wire_drawing_change(wm:Wire_Module, last_dir:Direction, new_dir:Direction) {
		// Handle dir change
		if(new_dir != last_dir) {
			// Reset initial click var if set
			if(drawing_wires_initial_click) drawing_wires_initial_click = false;
			// Grab useful vars
			var last_dir_status = wm.get_wire_status(last_dir);
			var new_dir_status = wm.get_wire_status(new_dir);
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
					wm.set_wire_status(last_dir, off);
				}
			}
			// If moving from non-entry dir to entry dir and both are enabled, enter backwards mode and delete
			else if(new_dir == drawing_entry_dir && last_enabled) {
				drawing_backwards = true;
				wm.set_wire_status(last_dir, disabled);
				// Set new_dir to entry_dir
				drawing_entry_dir = new_dir;
			}
			// If going backwards with no entry dir, disable last_dir
			else if(drawing_backwards && drawing_entry_dir == NODIR) {
				wm.set_wire_status(last_dir, disabled);
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
	  			wm.draw_module(grid_x + c*module_side_length, grid_y + r*module_side_length, simulating);
  			}
  		}
  	}

  	var holding_tool = false;
  	var held_tool : Tool;

  	function handle_and_draw_toolbar(simulating:Bool) {
  		// Handle tool dropping
  		if(holding_tool && Mouse.leftreleased() && Mouse.y >= grid_y && Mouse.x >= grid_x) {
  			var target_cell = { r: Std.int((Mouse.y - grid_y)/module_side_length), c: Std.int((Mouse.x - grid_x)/module_side_length) };
  			var target_wm = get_module_from_cell(target_cell);
  			if(target_wm != null) {
  				wire_grid[target_cell.r][target_cell.c] = new_module_from_tool(held_tool, target_cell, target_wm);
  			}
  		}
  		// Backup tool_holding stop
  		if(holding_tool && !Mouse.leftheld()) {
  			holding_tool = false;
  		}

  		// Draw toolbar
  		var sprite_offset = Math.round((module_side_length - tool_side_length)/2);
  		for(i in 0...tools.length) {
  			var x = tool_x + 1 + (i%tool_cols)*(tool_side_length+1);
  			var y = tool_y + 1 + Std.int(i/tool_cols)*(tool_side_length+1);
  			var sprite_x = x - sprite_offset;
  			var sprite_y = y - sprite_offset;
  			Gfx.drawbox(x-1, y-1, tool_side_length+2, tool_side_length+2, outline_color);
  			var tile_fill_color = tile_background_color;
  			// Respond to hover and TEMPORARILY HERE RESPOND TO DRAG
  			if(!simulating && !holding_tool && Geom.inbox(Mouse.x, Mouse.y, x, y, tool_side_length, tool_side_length)) {
  				tile_fill_color = tile_focus_color;
  				if(!simulating && Mouse.leftclick()) {
  					holding_tool = true;
  					held_tool = tools[i].tool;
  				}
  			}
  			Gfx.fillbox(x, y, tool_side_length, tool_side_length, tile_fill_color);
  			Gfx.drawtile(sprite_x, sprite_y, module_sheet_name, tools[i].tool);
  			// Draw name
  			Text.display(x+1, y+1, tools[i].name);
  		}

  		// Draw ghost when holding
  		if(holding_tool) {
  			var drag_sprite_offset = Std.int(module_side_length/2);
  			Gfx.drawtile(Mouse.x-drag_sprite_offset, Mouse.y-drag_sprite_offset, module_sheet_name, held_tool);
  		}
  	}



  	/* CELL HELPERS
 	=============== */
 	public function get_module_from_cell(c:Cell):Wire_Module {
 		if(c.r >= 0 && c.r < grid_height && c.c >= 0 && c.c < grid_width)
 			return wire_grid[c.r][c.c];
 		return null;
 	}

 	public function get_up_neighbor(c:Cell) { return get_module_from_cell({ r:c.r-1, c:c.c }); }
 	public function get_down_neighbor(c:Cell) { return get_module_from_cell({ r:c.r+1, c:c.c }); }
 	public function get_left_neighbor(c:Cell) { return get_module_from_cell({ r:c.r, c:c.c-1 }); }
 	public function get_right_neighbor(c:Cell) { return get_module_from_cell({ r:c.r, c:c.c+1 }); }

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

 	public function new_module_from_tool(tool:Tool, cell:Cell, ?wm:Wire_Module) {
 		return switch(tool) {
 			case wire: new Wire_Module(cell, wm);
 			case power: new Power_Module(cell, wm);
 			case or_diode: new Diode_Module(cell, wm);
 			case and_diode: Diode_Module.new_and_diode(cell, wm);
 			case emittor: new Emittor_Module(cell, wm);
 			case reciever: Reciever_Module.new_registered_reciever_module(this.signal_manager, cell, wm);
 			case bridge: new Bridge_Module(cell, wm);
 			default: null;
 		}
 	}

 	// Assumes there will never be a grid with more than 32 length 
	public static function cell_hash(c:Cell):Int {
 		return (c.r<<5) + c.c;
 	}
 	public static function cell_unhash(n:Int):Cell {
 		return { r: n>>5, c: n & 31 };
 	}

}