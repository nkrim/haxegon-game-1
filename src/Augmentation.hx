import haxegon.*;
import Main;
import Main.Cell;
import Wire_Module.*;
import Wire_Module.Module_Sheet;
import Modules.Diode_Module;
import Signal_Manager.*;
import Signal_Manager.Signal_Reciever;

interface Augmentation extends Signal_Reciever {}

/* TOGGLE AUGMENTATION
====================== */
class Toggle_Augmentation implements Augmentation { 

	// Protected vars
	var starting_state : Bool = true;
	var channel : Int;
	var active_state : Bool;

	// Constructor
	public function new(sm:Signal_Manager, ?channel:Int=0) {
		this.channel = channel;
		this.active_state = this.starting_state;

		// Register w/ signal manager
		sm.add_aug_reciever(this.channel, this);
	}

	public function get_starting_state() {
		return this.starting_state;
	}
	public function get_active_state() {
		return this.active_state;
	}
	public function toggle_starting_state() {
		this.starting_state = this.active_state = !this.starting_state;
	}


	// Signal_Reciever implementations
	public function get_channel() {
		return channel;
	}
	public function change_channel(channel: Int, sm: Signal_Manager):Void {
		sm.remove_aug_reciever(this.channel, this);
		this.channel = channel;
		sm.add_aug_reciever(this.channel, this);
	}
	public function recieve_signal(game:Main):Void {
		this.active_state = !this.active_state;
	}


	/* INTERACTION
	-------------- */
	public function reset() {
		this.active_state = this.starting_state;
	}

	/* RENDERING
	------------ */
	public function draw(x:Int, y:Int) {
		if(!this.active_state) 
			Gfx.fillbox(x, y, Main.module_side_length, Main.module_side_length, 0x000000, 0.5);
		Gfx.drawtile(x, y, module_sheet_name, this.active_state ? Module_Sheet.toggle_on : Module_Sheet.toggle_off);
		Gfx.imagecolor = Signal_Manager.channels[this.channel];
		Gfx.drawtile(x, y, module_sheet_name, Module_Sheet.toggle_color_mask);
		Gfx.resetcolor();
	}
}



/* ROTATOR AUGMENTATION
====================== */
class Rotator_Augmentation implements Augmentation { 

	// Protected vars
	var cell : Cell;
	var channel : Int;
	var rotation_index : Int;

	// Constructor
	public function new(cell:Cell, sm:Signal_Manager, ?channel:Int=0) {
		this.cell = cell;
		this.channel = channel;
		this.rotation_index = 0;

		// Register w/ signal manager
		sm.add_aug_reciever(this.channel, this);
	}


	public function get_rotation_index() {
		return this.rotation_index;
	}


	// Signal_Reciever implementations
	public function get_channel() {
		return channel;
	}
	public function change_channel(channel: Int, sm: Signal_Manager):Void {
		sm.remove_aug_reciever(this.channel, this);
		this.channel = channel;
		sm.add_aug_reciever(this.channel, this);
	}
	public function recieve_signal(game:Main):Void {
		this.rotation_index = (this.rotation_index + 1)%4;
		this.rotate_module(game);
	}


	/* INTERACTION
	-------------- */
	public function reset(game:Main) {
		this.rotate_module(game, 4 - this.rotation_index);
		this.rotation_index = 0;
	}

	public function rotate_module(game:Main, ?num_rots:Int=1) {
		num_rots = num_rots%4;
		if(num_rots == 0)
			return;
		var wm = game.get_module_from_cell(this.cell);
		if(wm == null)
			return;
		var temp_status = wm.up;
		switch(num_rots) {
			case 1: {
				wm.up = wm.left;
				wm.left = wm.down;
				wm.down = wm.right;
				wm.right = temp_status;
			}
			case 2: {
				wm.up = wm.down;
				wm.down = temp_status;
				temp_status = wm.left;
				wm.left = wm.right;
				wm.right = temp_status;
			}
			case 3: {
				wm.up = wm.right;
				wm.right = wm.down;
				wm.down = wm.left;
				wm.left = temp_status;
			}
			default: null;
		}

		// Rotate outputs in diode
		try {
			var diode = cast(wm, Diode_Module);
			diode.rotate_outputs(num_rots);
		}
		catch(msg:String) { }
	}

	/* RENDERING
	------------ */
	public function draw(x:Int, y:Int) {
		var main_sprite = Module_Sheet.rotator_up_main + 2*rotation_index;
		var color_sprite = Module_Sheet.rotator_up_color + 2*rotation_index;
		Gfx.drawtile(x, y, module_sheet_name, main_sprite);
		Gfx.imagecolor = Signal_Manager.channels[this.channel];
		Gfx.drawtile(x, y, module_sheet_name, color_sprite);
		Gfx.resetcolor();
	}
}
