import haxegon.*;
import Main;
import Map;
import Reflect;


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


/* TYPEDEFS
=========== */
typedef Channel_Data = {
	queued_signals: Int,
	recievers: Array<Signal_Reciever>,
}


/* SIGNAL_MANAGER
================= */
class Signal_Manager {

	// SIGNALS OPERATIONS
	public static var channels = [
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

	// Constructor
	public function new() {
		// Init channel_reciever_map with empty arrays for each channel
		this.channel_data_map = new Array<Channel_Data>();
		for(c in Signal_Manager.channels) {
			this.channel_data_map.push( { queued_signals: 0, recievers: new Array<Signal_Reciever>() } );
		}
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
		trace(channel);
		this.channel_data_map[channel].recievers.push(reciever);
	}
	public function remove_reciever(channel: Int, reciever: Signal_Reciever):Bool {
		if(reciever == null)
			return false;
		return this.channel_data_map[channel].recievers.remove(reciever);
	}

	/* Interactions
	--------------- */
	public function send_signal_to_channel(channel: Int) {
		this.channel_data_map[channel].queued_signals++;
	}

	// Resolves only one queued signal per-channel, to perform resolutions on a tick-by-tick basis
	public function resolve_signals_once(game:Main):Bool {
		var resolved_any_signals = false;
		for(data in this.channel_data_map) {
			if(data.queued_signals > 0) {
				resolved_any_signals = true;
				data.queued_signals--;
				for(reciever in data.recievers) {
					reciever.recieve_signal(game);
				}
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
		}
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