import haxegon.*;
import Main.*;
import Main.Cell;
import Main.Direction;
import Wire_Module.*;
import Wire_Module.Wire_Status;
import Wire_Module.Module_Sheet;


/* POWER MODULE
=============== */
class Power_Module extends Wire_Module {
	public override function start_power_tick(game : Main) {
		var up_neighbor = null;
		if(this.up != disabled) {
			this.up = on;
			up_neighbor = game.get_up_neighbor(this.cell);
		}
		var down_neighbor = null;
		if(this.down != disabled) {
			this.down = on;
			down_neighbor = game.get_down_neighbor(this.cell);
		}
		var right_neighbor = null;
		if(this.right != disabled) {
			this.right = on;
			right_neighbor = game.get_right_neighbor(this.cell);
		}
		var left_neighbor = null;
		if(this.left != disabled) {
			this.left = on;
			left_neighbor = game.get_left_neighbor(this.cell);
		}
		// RESOLVE CHANGED POWER SPREADING
		if(up_neighbor != null) { up_neighbor.handle_power_input(game, DOWN); }
		if(down_neighbor != null) { down_neighbor.handle_power_input(game, UP); }
		if(right_neighbor != null) { right_neighbor.handle_power_input(game, LEFT); }
		if(left_neighbor != null) { left_neighbor.handle_power_input(game, RIGHT); }
	}

	public override function handle_power_input(game : Main, dir : Direction) { }

	public override function draw_module(x:Int, y:Int, simulating:Bool) {
		super.draw_module(x, y, simulating);
		Gfx.drawtile(x, y, module_sheet_name, simulating ? Module_Sheet.power_on : Module_Sheet.power_off);
	}
}


/* BRIDGE MODULE
================ */
class Bridge_Module extends Wire_Module {

	public override function handle_power_input(game : Main, dir : Direction) { 
		var input_status = get_wire_status(dir);
		if(input_status != off)
			return;
		if(dir == UP || dir == DOWN) {
			if(this.up != disabled) this.up = on;
			if(this.down != disabled) this.down = on;
		}
		else {
			if(this.left != disabled) this.left = on;
			if(this.right != disabled) this.right = on;
		}
		var bridge_to_neighbor = switch(dir) {
			case UP: game.get_down_neighbor(this.cell);
			case DOWN: game.get_up_neighbor(this.cell);
			case RIGHT: game.get_left_neighbor(this.cell);
			case LEFT: game.get_right_neighbor(this.cell);
			default: null;
		}
		if(bridge_to_neighbor != null) {
			bridge_to_neighbor.handle_power_input(game, dir);
		}
	}

	public override function draw_module(x:Int, y:Int, simulating:Bool) {
		super.draw_module(x, y, simulating);
		var vert_powered = this.up == on || this.down == on;
		var horiz_powered = this.left == on || this.right == on;
		var sprite = Module_Sheet.bridge_off;
		if(vert_powered && horiz_powered)
			sprite = Module_Sheet.bridge_on_both;
		else if(horiz_powered)
			sprite = Module_Sheet.bridge_on_horiz;
		else if(vert_powered)
			sprite = Module_Sheet.bridge_on_vert;
		Gfx.drawtile(x, y, module_sheet_name, sprite);
	}
}


/* DIODE MODULE
=============== */
class Diode_Module extends Wire_Module {

	public var and_diode : Bool;
	public var up_output : Bool;
	public var down_output : Bool;
	public var right_output : Bool;
	public var left_output : Bool;

	public override function new(cell:Cell, ?wm:Wire_Module) {
		super(cell, wm);
		// Attempt to cast wm to a Diode_Module
		var valid_cast = true;
		var dwm : Diode_Module = null;
		try {
			dwm = cast (wm, Diode_Module);
		}
		catch ( cannot_cast_msg : String ) {
			valid_cast = false;
		}
		// If a valid_cast and dwm exists, use it's values to fill this module's
		if(valid_cast && dwm != null) {
			this.and_diode = false; //dwm.and_diode; // Taken out because tools are now separate
			this.up_output = dwm.up_output;
			this.down_output = dwm.down_output;
			this.right_output = dwm.right_output;
			this.left_output = dwm.left_output;
		}
		else {
			this.and_diode = false;
			this.up_output = false;
			this.down_output = false;
			this.right_output = false;
			this.left_output = false;
		}
	}
	public static function new_and_diode(cell:Cell, ?wm:Wire_Module) {
		var diode = new Diode_Module(cell, wm);
		diode.and_diode = true;
		return diode;
	}

	public override function handle_power_input(game : Main, dir : Direction) { 
		var input_status = get_wire_status(dir);
		if(input_status != off)
			return;
		// Set the input wire on
		set_wire_status(dir, on);
		// If the input is an output_wire, exit
		if(is_output(dir))
			return;

		// If or_diode, or and_diode w/ all inputs on, send to outputs
		if(should_send_power(true)) {
			var up_neighbor = null;
			if(this.up_output && this.up == off) {
				this.up = on;
				up_neighbor = game.get_up_neighbor(this.cell);
			}
			var down_neighbor = null;
			if(this.down_output && this.down == off) {
				this.down = on;
				down_neighbor = game.get_down_neighbor(this.cell);
			}
			var right_neighbor = null;
			if(this.right_output && this.right == off) {
				this.right = on;
				right_neighbor = game.get_right_neighbor(this.cell);
			}
			var left_neighbor = null;
			if(this.left_output && this.left == off) {
				this.left = on;
				left_neighbor = game.get_left_neighbor(this.cell);
			}
			// RESOLVE CHANGED POWER SPREADING
			if(up_neighbor != null) { up_neighbor.handle_power_input(game, DOWN); }
			if(down_neighbor != null) { down_neighbor.handle_power_input(game, UP); }
			if(right_neighbor != null) { right_neighbor.handle_power_input(game, LEFT); }
			if(left_neighbor != null) { left_neighbor.handle_power_input(game, RIGHT); }
		}
	}

	public override function draw_module(x:Int, y:Int, simulating:Bool) {
		super.draw_module(x, y, simulating);
		var powered = should_send_power();
		// Draw and_base and inputs, if and_diode
		if(and_diode) {
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_and_on : Module_Sheet.diode_and_off);
			if(!this.up_output && this.up == on)
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.diode_in_up_on);
			if(!this.down_output && this.down == on)
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.diode_in_down_on);
			if(!this.right_output && this.right == on)
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.diode_in_right_on);
			if(!this.left_output && this.left == on)
				Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.diode_in_left_on);
		}
		// Else draw or_base
		else {
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_on : Module_Sheet.diode_off);
		}
		// Draw outputs
		if(this.up_output)
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_out_up_on : Module_Sheet.diode_out_up_off);
		if(this.down_output)
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_out_down_on : Module_Sheet.diode_out_down_off);
		if(this.right_output)
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_out_right_on : Module_Sheet.diode_out_right_off);
		if(this.left_output)
			Gfx.drawtile(x, y, module_sheet_name, powered ? Module_Sheet.diode_out_left_on : Module_Sheet.diode_out_left_off);
	}

	public override function get_dir_setting_status(dir:Direction) {
		return switch(dir) {
			case UP: this.up_output;
			case DOWN: this.down_output;
			case RIGHT: this.right_output;
			case LEFT: this.left_output;
			default: false;
		}
	}
	public override function set_dir_setting_status(dir:Direction, val:Bool) {
		switch(dir) {
			case UP: this.up_output = val;
			case DOWN: this.down_output = val;
			case RIGHT: this.right_output = val;
			case LEFT: this.left_output = val;
			default: null;
		}
	}

	// Helpers
	public function is_output(dir:Direction) {
		return switch(dir) {
			case UP: up_output;
			case DOWN: down_output;
			case RIGHT: right_output;
			case LEFT: left_output;
			default: false;
		}
	}

	public function should_send_power(?any_input_powered:Bool) {
		any_input_powered = any_input_powered || (!this.up_output && this.up == on) || (!this.down_output && this.down == on)
							|| (!this.left_output && this.left == on) || (!this.right_output && this.right == on);
		// If or_diode
		if(!this.and_diode)
			return any_input_powered;
		// If and_diode
		return any_input_powered
				&& (this.up_output || this.up == on) && (this.down_output || this.down == on) 
				&& (this.left_output || this.left == on) && (this.right_output || this.right == on);
	}
}


/* EMITTOR MODULE
================= */
class Emittor_Module extends Wire_Module implements Signal_Emittor {

	// Public vars
	public var channel : Signal;

	// Constructor
	public override function new(cell:Cell, ?wm:Wire_Module) {
		super(cell, wm);

		this.channel = Signal.green;
	}

	// Overrides
	public override function handle_power_input(game : Main, dir : Direction) { 
		var input_status = get_wire_status(dir);
		if(input_status != off)
			return;
		// Set the input wire on
		set_wire_status(dir, on);

		// Send signal (STRUCTUE NOT YET IMPLEMENTED)
	}

	public override function draw_module(x:Int, y:Int, simulating:Bool) {
		super.draw_module(x, y, simulating);
		// Draw base
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.emittor_base);
		// Set color and draw on mask
		Gfx.imagecolor = this.channel.color;
		// If there are no inputs on, reduce the alpha
		if(this.up != on && this.down != on && this.left != on && this.left != on)
			Gfx.imagealpha = 0.65;
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.module_color_mask);
		Gfx.imagealpha = 1;
		Gfx.resetcolor();
		// Draw inputs, where valid
		if(this.up == on)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.emittor_up_on);
		if(this.down == on)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.emittor_down_on);
		if(this.left == on)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.emittor_left_on);
		if(this.right == on)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.emittor_right_on);

	}	
}


/* RECIEVER MODULE
================== */
class Reciever_Module extends Wire_Module implements Signal_Reciever {

	// Public vars
	public var channel : Signal;

	// Protected vars
	var incoming_signal : Bool;

	// Constructor
	public override function new(cell:Cell, ?wm:Wire_Module) {
		super(cell, wm);

		this.channel = Signal.green;
		this.incoming_signal = false;
	}

	// Overrides
	public override function handle_power_input(game : Main, dir : Direction) { 
		var input_status = get_wire_status(dir);
		if(input_status != off)
			return;
		// Set the input wire on
		set_wire_status(dir, on);
	}

	public override function draw_module(x:Int, y:Int, simulating:Bool) {
		super.draw_module(x, y, simulating);
		// Draw base
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.reciever_base);
		// Set color and draw on mask
		Gfx.imagecolor = this.channel.color;
		// If there's no incoming_signal, reduce the alpha
		if(!this.incoming_signal)
			Gfx.imagealpha = 0.65;
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.module_color_mask);
		Gfx.imagealpha = 1;
		Gfx.resetcolor();
		// Draw outputs, if there's an incoming_signal
		if(this.incoming_signal)
			Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.reciever_on);

	}

	// Member functions
	public function recieve_signal(game:Main) {
		if(this.incoming_signal)
			return;

		this.incoming_signal = true;
		var up_neighbor = null;
		if(this.up == off) {
			this.up = on;
			up_neighbor = game.get_up_neighbor(this.cell);
		}
		var down_neighbor = null;
		if(this.down == off) {
			this.down = on;
			down_neighbor = game.get_down_neighbor(this.cell);
		}
		var right_neighbor = null;
		if(this.right == off) {
			this.right = on;
			right_neighbor = game.get_right_neighbor(this.cell);
		}
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
}