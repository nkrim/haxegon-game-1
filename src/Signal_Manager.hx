import haxegon.*;
import Main;
import Map;
import Reflect;
import Augmentation;


/* INTERACES
============ */
interface Signal_Emittor {
	public var channel : Int;
}
interface Signal_Reciever {
	public function get_channel():Int;
	public function change_channel(channel: Int, sm: Signal_Manager):Void;
	public function recieve_signal(game:Main):Void;
}
interface Universal_Signal_Reciever {
	public function recieve_all_signals(channels:Array<Int>, game:Main):Void;
}


/* TYPEDEFS
=========== */
typedef Channel_Data = {
	queued_signals: Int,
	recievers: Array<Signal_Reciever>,
	aug_recievers: Array<Augmentation>,
}


/* SIGNAL_MANAGER
================= */
class Signal_Manager {

	// SIGNALS OPERATIONS
	public static var channels:Array<Int> = [
		0x06aa00,
		0x1e44fa,
		0xf51515,
		0xffed00,
		0x00ffca,
		0xc600e6,
		0xff9e00,
		0xb2ff1f,
		0xff009e,
		0x854500,
		0x8a8a8a,
		0xffffff,
	];

	// protected vars
	var channel_data_map : Array<Channel_Data>;
	var tick_channel_signals : Array<Int>;
	var universal_recievers : Array<Universal_Signal_Reciever>;

	// Constructor
	public function new() {
		// Init channel_reciever_map with empty arrays for each channel
		this.channel_data_map = new Array<Channel_Data>();
		for(c in Signal_Manager.channels) {
			this.channel_data_map.push( { 
				queued_signals: 0, 
				recievers: new Array<Signal_Reciever>(),
				aug_recievers: new Array<Augmentation>(),
			} );
		}
		this.tick_channel_signals = [for (c in Signal_Manager.channels) 0];

		// Init universal_recievers
		this.universal_recievers = new Array<Universal_Signal_Reciever>();
	}

	// Accessors
	public function get_channel_recievers(channel: Int) {
		return this.channel_data_map[channel].recievers;
	}
	public function get_channel_queued_signals(channel: Int) {
		return this.channel_data_map[channel].queued_signals;
	}

	// Modifiers
	public function add_reciever(channel: Int, reciever: Signal_Reciever):Void {
		if(reciever == null)
			return;
		this.channel_data_map[channel].recievers.push(reciever);
	}
	public function remove_reciever(channel: Int, reciever: Signal_Reciever):Bool {
		if(reciever == null)
			return false;
		return this.channel_data_map[channel].recievers.remove(reciever);
	}
	public function add_aug_reciever(channel: Int, reciever: Augmentation):Void {
		if(reciever == null)
			return;
		this.channel_data_map[channel].aug_recievers.push(reciever);
	}
	public function remove_aug_reciever(channel: Int, reciever: Augmentation):Bool {
		if(reciever == null)
			return false;
		return this.channel_data_map[channel].aug_recievers.remove(reciever);
	}
	public function add_universal_reciever(reciever:Universal_Signal_Reciever):Void {
		if(reciever == null)
			return;
		this.universal_recievers.push(reciever);
	}
	public function remove_universal_reciever(reciever:Universal_Signal_Reciever):Bool {
		if(reciever == null)
			return false;
		return this.universal_recievers.remove(reciever);
	}
	/* Interactions
	--------------- */
	public function send_signal_to_channel(channel: Int) {
		this.channel_data_map[channel].queued_signals++;
		this.tick_channel_signals[channel]++;
	}

	// Resolves only one queued signal per-channel, to send 1 of each active signal to all universal receivers
	// WORKS ONLY ON TICK_CHANNEL_SIGNALS, AND RESETS THIS ARRAY AFTER IT IS DONE
	public function resolve_universal_signals_once(game:Main) {
		var active_channels = new Array<Int>();
		for(i in 0...this.channel_data_map.length) {
			var queued_signals = this.tick_channel_signals[i];
			while(queued_signals-- > 0) {
				active_channels.push(i);
			}
		}
		if(active_channels.length > 0) {
			for(universal_reciever in this.universal_recievers)
				universal_reciever.recieve_all_signals(active_channels, game);
			this.tick_channel_signals = [for (c in Signal_Manager.channels) 0];
		}
	}
	// Resolves only one queued signal per-channel, to perform resolutions on a tick-by-tick basis
	public function resolve_signals_once(game:Main):Bool {
		var resolved_any_signals = false;
		// Copy queued_signals into new array so as not to be corrupted by resolutions
		var copy_queue_signals = new Array<Int>();
		for(data in this.channel_data_map)
			copy_queue_signals.push(data.queued_signals);

		// Resolve aug_recievers first
		for(i in 0...this.channel_data_map.length) {
			var queued_signals = copy_queue_signals[i];
			var data = this.channel_data_map[i];
			if(queued_signals > 0) {
				for(aug_reciever in data.aug_recievers) {
					aug_reciever.recieve_signal(game);
				}
			}
		}
		// Resolve recievers second
		for(i in 0...this.channel_data_map.length) {
			var queued_signals = copy_queue_signals[i];
			var data = this.channel_data_map[i];
			if(queued_signals > 0) {
				resolved_any_signals = true;
				for(reciever in data.recievers) {
					reciever.recieve_signal(game);
				}
				// Decrement the persistent queued_signals
				data.queued_signals--;
			}
		}
		return resolved_any_signals;
	}

	public function clear_queued_signals() {
		for(data in this.channel_data_map) {
			data.queued_signals = 0;
		}
	}

	public function reset_signal_manager() {
		for(data in this.channel_data_map) {
			data.queued_signals = 0;
			data.recievers = new Array<Signal_Reciever>();
			data.aug_recievers = new Array<Augmentation>();
		}
		this.universal_recievers = new Array<Universal_Signal_Reciever>();
	}

	/* Helper Procedures
	-------------------- */
	public static function cast_to_emittor(wm:Wire_Module) {
		try {
			return cast(wm, Signal_Emittor);
		}
		catch(msg:String) {
			return null;
		}
	}
	public static function cast_to_reciever(wm:Wire_Module) {
		try {
			return cast(wm, Signal_Reciever);
		}
		catch(msg:String) {
			return null;
		}
	}

	public static function get_channel_from_module(wm:Wire_Module):Int {
		var emittor = cast_to_emittor(wm);
		if(emittor != null)
			return emittor.channel;
		var reciever = cast_to_reciever(wm);
		if(reciever != null)
			return reciever.get_channel();
		return -1;
	}

	public static function set_channel_for_module(wm:Wire_Module, new_channel: Int, sm: Signal_Manager):Bool {
		var emittor = cast_to_emittor(wm);
		if(emittor != null) {
			emittor.channel = new_channel;
			return true;
		}
		var reciever = cast_to_reciever(wm);
		if(reciever != null) {
			reciever.change_channel(new_channel, sm);
			return true;
		}
		return false;
	}
}