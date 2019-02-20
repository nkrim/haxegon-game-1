import haxegon.*;
import Main.*;
import Main.Direction;

/* WIRE SPRITE SHEET MAPPINGS */
@:enum
abstract Wire_Sheet(Int) from Int to Int {
  	var base 			=  0;
  	var center_shadow   =  1;
	var center_off 		=  2;
	var center_on		=  3;
	var up_shadow		=  4;
	var up_off			=  5;
	var up_in			=  6;
	var up_both			=  7;
	var up_out			=  8;
	var down_shadow     =  9;
	var down_off		= 10;
	var down_in			= 11;
	var down_both		= 12;
	var down_out		= 13;
	var left_shadow     = 14;
	var left_off		= 15;
	var left_in			= 16;
	var left_both		= 17;
	var left_out		= 18;
	var right_shadow    = 19;
	var right_off		= 20;
	var right_in		= 21;
	var right_both		= 22;
	var right_out		= 23;
}

/* ENUM CLASSES */
@:enum
abstract Wire_Status(Int) from Int to Int {
	var disabled	= -1;
	var off 		= 0;
	var pow_in		= 1;
	var pow_out 	= 2;
	var pow_both 	= 3;

	@:op(A + B)
	public function add(b:Int):Int {
		return this + b;
	}
}

typedef Wire_Module = {
	up : Wire_Status,
	down : Wire_Status,
	right : Wire_Status,
	left : Wire_Status,
	hovering: Direction,
}


class Wire {

	public static inline function init_wire_module() : Wire_Module {
		return { up : disabled, down : disabled, right : disabled, left : disabled, hovering : NODIR };
	}

	/* INTERACTION
	============== */
	public static function get_wire_status(wm:Wire_Module, dir:Main.Direction) {
		return switch(dir) {
			case UP: wm.up;
			case DOWN: wm.down;
			case LEFT: wm.left;
			case RIGHT: wm.right;
			default: disabled;
		}
	}

	public static function set_wire_status(wm:Wire_Module, dir:Main.Direction, status:Wire_Status) {
		switch(dir) {
			case UP: wm.up = status;
			case DOWN: wm.down = status;
			case LEFT: wm.left = status;
			case RIGHT: wm.right = status;
			default: return;
		}
	}


	/* RENDERING 
	============ */
	static var wire_sheet_name = "wire_sheet";

	static var hover_opacity_off = 0.35;
	static var hover_opacity_on = 0.75;

	public static function load_wire_spritesheet() {
		Gfx.loadtiles(wire_sheet_name, 65, 65);
	}

	public static function draw_wire_module(x:Int, y:Int, wm:Wire_Module, simulating:Bool) {
		// BASE
		Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.base);

		// HOVER
		var hover = wm.hovering;
		wm.hovering = NODIR;

		// CENTER
		if(wm.up == disabled && wm.down == disabled && wm.left == disabled && wm.right == disabled) {
			if(hover != NODIR) {
				Gfx.imagealpha = hover_opacity_off;
				Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_off);
				Gfx.imagealpha = 1;
			}
			else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_shadow);
		}
		else if(wm.up == pow_in || wm.down == pow_in || wm.left == pow_in || wm.right == pow_in)
			Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_on);
		
		else {
			// If sum of wire_statuses == -3 then 3 are disabled and 1 is off
			if(
			(wm.up + wm.down + wm.left + wm.right) == -3 &&
			wm.up == off && hover == UP ||
			wm.down == off && hover == DOWN ||
			wm.left == off && hover == LEFT ||
			wm.right == off && hover == RIGHT
			)
				Gfx.imagealpha = hover_opacity_on;
			Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_off);
			Gfx.imagealpha = 1;
		}
		// UP
		switch(wm.up) {
			case disabled: 	{
				if(hover == UP) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_shadow);
			}
			case off: 		{ 
				if(hover == UP)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_off);
				Gfx.imagealpha = 1;
			}
			case pow_in: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_in);
			case pow_out: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_out);
			case pow_both: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_both);
		}
		// DOWN
		switch(wm.down) {
			case disabled: 	{
				if(hover == DOWN) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_shadow);
			}
			case off: 		{ 
				if(hover == DOWN)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_off);
				Gfx.imagealpha = 1;
			}
			case pow_in: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_in);
			case pow_out: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_out);
			case pow_both: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_both);
		}
		// LEFT
		switch(wm.left) {
			case disabled: 	{
				if(hover == LEFT) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_shadow);
			}
			case off: 		{ 
				if(hover == LEFT)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_off);
				Gfx.imagealpha = 1;
			}
			case pow_in: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_in);
			case pow_out: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_out);
			case pow_both: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_both);
		}
		// RIGHT
		switch(wm.right) {
			case disabled: 	{
				if(hover == RIGHT) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_shadow);
			}
			case off: 		{ 
				if(hover == RIGHT)
					Gfx.imagealpha = hover_opacity_on;
				Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_off);
				Gfx.imagealpha = 1;
			}
			case pow_in: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_in);
			case pow_out: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_out);
			case pow_both: 	Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_both);
		}
	}
}