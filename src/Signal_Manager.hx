import haxegon.*;
import Main;

/* SIGNAL_ENUM
============== */
typedef Signal_Data = {
	index : Int,
	color : Int,
}
@:enum
abstract Signal {
	var green:Signal_Data = {
		index: 0,
		color: 0x75e02b,
	}
}


/* INTERACES
============ */
interface Signal_Emittor {
	public var channel : Signal;
	public function send_signal(manager:Signal_Manager);
}
interface Signal_Reciever {
	public var channel : Signal;
	public function recieve_signal(game:Main);
}



/* SIGNAL_MANAGER
================= */
class Signal_Manager {

}