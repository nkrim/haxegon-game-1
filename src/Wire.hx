import haxegon.*;
import Main.*;

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

@:enum
abstract Wire_Hover(Int) from Int to Int {
	var none_hover   	= 0;
	var center_hover 	= 1;
	var up_hover 	 	= 2;
	var down_hover 		= 3;
	var left_hover		= 4;
	var right_hover		= 5;
}

typedef Wire_Module = {
	up : Wire_Status,
	down : Wire_Status,
	right : Wire_Status,
	left : Wire_Status,
}


class Wire {

	public static inline function init_wire_module() : Wire_Module {
		return { up : off, down : disabled, right : disabled, left : disabled };
	}

	/* INTERACTION
	============== */
	static var wire_width = 11;
	static var wire_length = 26;

	public static function wire_hover_status(x:Int, y:Int) {
		var mx = Mouse.x - x;
		var my = Mouse.y - y;

		if(mx < 0 || mx >= module_side_length || my < 0 || my >= module_side_length)
			return none_hover;
		else if(Geom.inbox(mx, my, wire_length+1, 0, wire_width, wire_length+1))
			return up_hover;
		else if(Geom.inbox(mx, my, wire_length+1, wire_length+wire_width+1, wire_width, wire_length))
			return down_hover;
		else if(Geom.inbox(mx, my, 0, wire_length+1, wire_length+1, wire_width))
			return left_hover;
		else if(Geom.inbox(mx, my, wire_length+wire_width+1, wire_length+1, wire_length, wire_width))
			return right_hover;
		else
			return none_hover;
	}

	public static function general_wire_hover_status(x:Int, y:Int) {
		var mx = Mouse.x - x;
		var my = Mouse.y - y;

		if(mx < 0 || mx >= module_side_length || my < 0 || my >= module_side_length)
			return none_hover;

		var upper_right = mx >= my;
		var lower_right = mx >= (module_side_length - my);

		if(upper_right) {
			if(lower_right)
				return right_hover;
			return up_hover;
		}
		if(lower_right)
			return down_hover;
		return left_hover;
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
		var hover = simulating ? none_hover : general_wire_hover_status(x, y);

		// CENTER
		if(wm.up == disabled && wm.down == disabled && wm.left == disabled && wm.right == disabled) {
			if(hover != none_hover) Gfx.imagealpha = hover_opacity_off;
			if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_shadow);
			Gfx.imagealpha = 1;
		}
		else if(wm.up == pow_in || wm.down == pow_in || wm.left == pow_in || wm.right == pow_in)
			Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_on);
		
		else {
			// If sum of wire_statuses == -3 then 3 are disabled and 1 is off
			if(
			(wm.up + wm.down + wm.left + wm.right) == -3 &&
			wm.up == off && hover == up_hover ||
			wm.down == off && hover == down_hover ||
			wm.left == off && hover == left_hover ||
			wm.right == off && hover == right_hover
			)
				Gfx.imagealpha = hover_opacity_on;
			Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.center_off);
			Gfx.imagealpha = 1;
		}
		// UP
		switch(wm.up) {
			case disabled: 	{
				if(hover == up_hover) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.up_shadow);
			}
			case off: 		{ 
				if(hover == up_hover)
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
				if(hover == down_hover) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.down_shadow);
			}
			case off: 		{ 
				if(hover == down_hover)
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
				if(hover == left_hover) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.left_shadow);
			}
			case off: 		{ 
				if(hover == left_hover)
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
				if(hover == right_hover) {
					Gfx.imagealpha = hover_opacity_off;
					Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_off);
					Gfx.imagealpha = 1;
				}
				else if(!simulating) Gfx.drawtile(x, y, wire_sheet_name, Wire_Sheet.right_shadow);
			}
			case off: 		{ 
				if(hover == right_hover)
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