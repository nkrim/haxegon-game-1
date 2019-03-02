import haxegon.*;
import Main.*;
import Main.Cell;
import Main.Direction;

/* WIRE SPRITE SHEET MAPPINGS */
@:enum
abstract Module_Sheet(Int) from Int to Int {
  	var base 					= 0;
  	var center_shadow   		= 1;
	var center_off 				= 2;
	var center_on				= 3;
	var up_shadow				= 4;
	var up_off					= 5;
	var up_on					= 6;
	var down_shadow     		= 7;
	var down_off				= 8;
	var down_on					= 9;
	var left_shadow     		= 10;
	var left_off				= 11;
	var left_on					= 12;
	var right_shadow    		= 13;
	var right_off				= 14;
	var right_on				= 15;
	var power_off 				= 16;
	var power_on 				= 17;
	var bridge_off 				= 18;
	var bridge_on_horiz			= 19;
	var bridge_on_both  		= 20;
	var bridge_on_vert  		= 21;
	var diode_off 				= 22;
	var diode_on 				= 23;
	var diode_out_up_off 		= 24;
	var diode_out_up_on 		= 25;
	var diode_out_down_off 		= 26;
	var diode_out_down_on 		= 27;
	var diode_out_left_off 		= 28;
	var diode_out_left_on 		= 29;
	var diode_out_right_off 	= 30;
	var diode_out_right_on 		= 31;
	var diode_in_up_off 		= 32;
	var diode_in_up_on 			= 33;
	var diode_in_down_off 		= 34;
	var diode_in_down_on 		= 35;
	var diode_in_left_off 		= 36;
	var diode_in_left_on 		= 37;
	var diode_in_right_off 		= 38;
	var diode_in_right_on 		= 39;
}

/* ENUM CLASSES */
@:enum
abstract Wire_Status(Int) from Int to Int {
	var disabled	= -1;
	var off 		= 0;
	var on 			= 1;

	@:op(A + B)
	public function add(b:Int):Int {
		return this + b;
	}
	@:op(A >= B)
	public function gte(b:Int):Bool {
		return this >= b;
	}
}


class Wire_Module {

	public var cell : Cell;
	// Basic wire input statuses
	public var up : Wire_Status;
	public var down : Wire_Status;
	public var right : Wire_Status;
	public var left : Wire_Status;
	// Hovering direction for redering
	public var hovering : Direction;

	// Augmentations on the module
	//public var augs : Augmentations;

	public function new(cell:Cell, ?wm:Wire_Module) {
		this.cell = cell;
		if(wm != null) {
			this.cell = wm.cell;
			this.up = wm.up;
			this.down = wm.down;
			this.right = wm.right;
			this.left = wm.left;
			this.hovering = wm.hovering;
		}
		else {
			this.up = disabled;
			this.down = disabled;
			this.right = disabled;
			this.left = disabled;
			this.hovering = NODIR;
		}
	}


	/* INTERACTION
	============== */
	public function get_wire_status(dir:Main.Direction) {
		return switch(dir) {
			case UP: this.up;
			case DOWN: this.down;
			case LEFT: this.left;
			case RIGHT: this.right;
			default: disabled;
		}
	}

	public function set_wire_status(dir:Main.Direction, status:Wire_Status) {
		switch(dir) {
			case UP: this.up = status;
			case DOWN: this.down = status;
			case LEFT: this.left = status;
			case RIGHT: this.right = status;
			default: null;
		}
	}


	/* MECHANICS
	============ */
	public function start_power_tick(game : Main) {}

	public function handle_power_input(game : Main, dir : Direction) {
		var input_status = get_wire_status(dir);
		if(input_status != off)
			return;
		this.set_wire_status(dir, on);
		// UP
		var up_neighbor = null;
		if(this.up == off) {
			this.up = on;
			up_neighbor = game.get_up_neighbor(this.cell);
		}
		// DOWN
		var down_neighbor = null;
		if(this.down == off) {
			this.down = on;
			down_neighbor = game.get_down_neighbor(this.cell);
		}
		// RIGHT
		var right_neighbor = null;
		if(this.right == off) {
			this.right = on;
			right_neighbor = game.get_right_neighbor(this.cell);
		}
		// LEFT
		var left_neighbor = null;
		if(this.left == off) {
			this.left = on;
			left_neighbor = game.get_left_neighbor(this.cell);
		}
		// RESOLVE CHANGED POWER SPREADING
		if(up_neighbor != null) { up_neighbor.handle_power_input(game, DOWN); }
		if(down_neighbor != null) { down_neighbor.handle_power_input(game, UP); }
		if(right_neighbor != null) { right_neighbor.handle_power_input(game, LEFT); }
		if(left_neighbor != null) { left_neighbor.handle_power_input(game, RIGHT); }
	}

	public function resolve_tick() {
		restart_module();
	}

	public function restart_module() {
		if(this.up == on)
			this.up = off;
		if(this.down == on)
			this.down = off;
		if(this.right == on)
			this.right = off;
		if(this.left == on)
			this.left = off;
	}


	/* RENDERING 
	============ */
	public static var module_sheet_name = "module_sheet";

	public static var hover_opacity_off = 0.35;
	public static var hover_opacity_on = 0.75;

	public static function load_wire_spritesheet() {
		Gfx.loadtiles(module_sheet_name, 65, 65);
	}

	// OVERLOADABLE
	public function draw_module(x:Int, y:Int, simulating:Bool) {
		// BASE
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.base);

		// HOVER
		var hover = this.hovering;
		this.hovering = NODIR;

		// CENTER
		if(this.up == disabled && this.down == disabled && this.left == disabled && this.right == disabled) {
			if(hover != NODIR) {
				Gfx.imagealpha = hover_opacity_off;
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.center_off);
				Gfx.imagealpha = 1;
			}
			else if(!simulating) Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.center_shadow);
		}
		else if(this.up == on || this.down == on || this.left == on || this.right == on)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.center_on);
		
		else {
			// If sum of wire_statuses == -3 then 3 are disabled and 1 is off
			if(
			(this.up + this.down + this.left + this.right) == -3 &&
			this.up == off && hover == UP ||
			this.down == off && hover == DOWN ||
			this.left == off && hover == LEFT ||
			this.right == off && hover == RIGHT
			)
				Gfx.imagealpha = hover_opacity_on;
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.center_off);
			Gfx.imagealpha = 1;
		}
		// UP
		switch(this.up) {
			case disabled: 	{
				if(hover == UP) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.up_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.up_shadow);
			}
			case off: 		{ 
				if(hover == UP)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.up_off);
				Gfx.imagealpha = 1;
			}
			case on: 	Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.up_on);
			default: null;
		}
		// DOWN
		switch(this.down) {
			case disabled: 	{
				if(hover == DOWN) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.down_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.down_shadow);
			}
			case off: 		{ 
				if(hover == DOWN)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.down_off);
				Gfx.imagealpha = 1;
			}
			case on: 	Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.down_on);
			default: null;
		}
		// LEFT
		switch(this.left) {
			case disabled: 	{
				if(hover == LEFT) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.left_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.left_shadow);
			}
			case off: 		{ 
				if(hover == LEFT)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.left_off);
				Gfx.imagealpha = 1;
			}
			case on: 	Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.left_on);
			default: null;
		}
		// RIGHT
		switch(this.right) {
			case disabled: 	{
				if(hover == RIGHT) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.right_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.right_shadow);
			}
			case off: 		{ 
				if(hover == RIGHT)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.right_off);
				Gfx.imagealpha = 1;
			}
			case on: 	Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.right_on);
			default: null;
		}
	}
}