import haxegon.*;
import Main.*;
import Main.Cell;
import Main.Direction;
import Augmentation.Toggle_Augmentation;

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
	var bridge_rot_off 			= 22;
	var bridge_rot_on_horiz		= 23;
	var bridge_rot_on_both  	= 24;
	var bridge_rot_on_vert  	= 25;
	var diode_off 				= 26;
	var diode_on 				= 27;
	var diode_and_off 			= 28;
	var diode_and_on 			= 29;
	var diode_out_up_off 		= 30;
	var diode_out_up_on 		= 31;
	var diode_out_down_off 		= 32;
	var diode_out_down_on 		= 33;
	var diode_out_left_off 		= 34;
	var diode_out_left_on 		= 35;
	var diode_out_right_off 	= 36;
	var diode_out_right_on 		= 37;
	var diode_in_up_on 			= 38;
	var diode_in_down_on 		= 39;
	var diode_in_left_on 		= 40;
	var diode_in_right_on 		= 41;
	var emittor_base_display	= 42;
	var reciever_base_display 	= 43;
	var reciever_base 			= 44;
	var emittor_base 			= 45;
	var module_color_mask		= 46;
	var reciever_on				= 47;
	var emittor_up_on 			= 48;
	var emittor_down_on 		= 49;
	var emittor_left_on 		= 50;
	var emittor_right_on		= 51;
	var toggle_on 				= 52;
	var toggle_off 				= 53;
	var toggle_color_mask 		= 54;
	var rotator_up_main 		= 55;
	var rotator_up_color 		= 56;
	var rotator_right_main 		= 57;
	var rotator_right_color 	= 58;
	var rotator_down_main 		= 59;
	var rotator_down_color 		= 60;
	var rotator_left_main 		= 61;
	var rotator_left_color 		= 62;
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
	public var outline : Bool;

	// Augmentations on the module
	public var toggle_aug : Toggle_Augmentation;

	public function new(cell:Cell, ?wm:Wire_Module) {
		this.cell = cell;
		if(wm != null) {
			this.up = wm.up;
			this.down = wm.down;
			this.right = wm.right;
			this.left = wm.left;
			this.hovering = wm.hovering;
			this.outline = wm.outline;
			this.toggle_aug = wm.toggle_aug;
		}
		else {
			this.up = disabled;
			this.down = disabled;
			this.right = disabled;
			this.left = disabled;
			this.hovering = NODIR;
			this.outline = false;
			this.toggle_aug = null;
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
		// If toggle_aug exists and is inactive, do nothing
		if(toggle_aug != null && !toggle_aug.get_active_state())
			return;

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

	public function get_dir_setting_status(dir:Direction) {
		return false;
	}
	public function set_dir_setting_status(dir:Direction, val:Bool) { }
	public function toggle_dir_setting_status(dir:Direction) {
		set_dir_setting_status(dir, !get_dir_setting_status(dir));
	}


	/* RENDERING 
	============ */
	public static var module_sheet_name = "module_sheet";

	public static var hover_opacity_off = 0.35;
	public static var hover_opacity_on = 0.75;

	public static function load_module_spritesheet() {
		Gfx.loadtiles(module_sheet_name, 65, 65);
	}

	// OVERLOADABLE
	public function draw_module(x:Int, y:Int, simulating:Bool) {
		// BASE
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.base);

		// AUGMENTATIONS
		if(this.toggle_aug != null) toggle_aug.draw(x, y);

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

		// Handle outline
		if(outline) {
			Gfx.drawbox(x, y, 65, 65, 0x999999);
			outline = false;
		}
	}
}