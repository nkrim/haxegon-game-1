import haxegon.*;
import Main;
import Wire_Module.*;
import Wire_Module.Module_Sheet;
import Signal_Manager.*;
import Signal_Manager.Signal_Reciever;

interface Augmentation extends Signal_Reciever {}

/* TOGGLE AUGMENTATION
====================== */
class Toggle_Augmentation implements Augmentation { 

	// Protected vars
	var channel : Int;
	var active_state : Bool;

	// Constructor
	public function new(sm:Signal_Manager, ?channel:Int=0) {
		this.channel = channel;
		this.active_state = true;

		// Register w/ signal manager
		sm.add_aug_reciever(this.channel, this);
	}


	public function get_active_state() {
		return this.active_state;
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
		this.active_state = true;
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