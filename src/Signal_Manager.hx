import haxegon.*;
import Main;
import Map;
import Reflect;


/* INTERACES
============ */
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
	public static var channels = {
		green: 0x75e02b,
	};

	// protected vars
	var channel_data_map : Map<Int,Channel_Data>;

	// Constructor
	public function new() {
		// Init channel_reciever_map with empty arrays for each channel
		this.channel_data_map = new Map<Int,Channel_Data>();
		for(f in Reflect.fields(channels)) {
			this.channel_data_map[Reflect.field(channels, f)] = { queued_signals: 0, recievers: new Array<Signal_Reciever>() };
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
		for(channel in this.channel_data_map.keys()) {
			var data = this.channel_data_map[channel];
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
		for(channel in this.channel_data_map.keys()) {
			var data = this.channel_data_map[channel];
			data.queued_signals = 0;
		}
	}
}