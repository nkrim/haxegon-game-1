import haxegon.*;
import Main;

/* CHANNEL DATA
=============== */
typedef Channel = {
	name : String,
	color : Int,
}
@:enum
abstract Channel_Index(Int) from Int to Int {
	var green = 0;
}

/* INTERACES
============ */
interface Signal_Emittor {
	public var channel : Channel;
	public function send_signal(manager:Signal_Manager):Void;
}
interface Signal_Reciever {
	public var channel : Channel;
	public function recieve_signal(game:Main):Void;
}



/* SIGNAL_MANAGER
================= */
class Signal_Manager {

	// SIGNALS OPERATIONS
	public static var channels = [
		{
			name: "green",
			color: 0x75e02b,
		},
	];
}