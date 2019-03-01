import haxegon.*;
import Main.*;
import Main.Direction;
import Wire_Module.*;
import Wire_Module.Wire_Status;
import Wire_Module.Module_Sheet;

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