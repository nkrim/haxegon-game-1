import haxegon.*;
import Main.Direction;
import Wire_Module;

/* TOOLTIP SPRITE SHEET MAPPINGS */
@:enum
abstract Tooltip_Sheet(Int) from Int to Int {
  	var dir_tab_disabled_hover	= 0;
  	var dir_tab_disabled   		= 1;
  	var dir_tab_enabled_hover	= 2;
  	var dir_tab_enabled 		= 3;
  	var sig_tab_disabled_hover	= 4;
  	var sig_tab_disabled   		= 5;
  	var sig_tab_enabled_hover	= 6;
  	var sig_tab_enabled 		= 7;
	var tog_tab_hover			= 8;
	var tog_tab 				= 9;
	var rot_tab_hover			= 10;
	var rot_tab					= 11;
	var bg_disabled				= 12;
	var bg_enabled	     		= 13;
	var dir_main				= 14;
	var dir_up_disabled			= 15;
	var dir_down_disabled 		= 16;
	var dir_left_disabled		= 17;
	var dir_right_disabled		= 18;
	var sig_main	 			= 19;
}


enum Tab {
	DIR;
	SIG;
	TOG;
	ROT;
}


class Tooltip {

	// Static vars
	public static var tooltip_sheet_name = "tooltip_sheet";

	// Public vars
	public var tab : Tab;

	// Protected vars
	var x : Int;
	var y : Int;
	var module : Wire_Module;

	var is_hovering_tab : Bool;
	var hovered_tab : Tab;

	var hovering_dir : Direction;
	var hovering_channel : Int;

	// Constructor
	public function new() {
		this.tab = DIR;

		this.x = 0;
		this.y = 0;
		this.module = null;

		this.is_hovering_tab = false;
		this.hovered_tab = DIR;
		this.hovering_dir = NODIR;
		this.hovering_channel = -1;
	}

	// Spritesheet loading
	public static function load_tooltip_spritesheet() {
		Gfx.loadtiles(tooltip_sheet_name, 65, 71);
	}

	// Placement
	public function set_position(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}

	// Module get/set
	public function get_module() { return this.module; }
	public function set_module(module:Wire_Module) {
		this.module = module;
		if(uses_dirs())
			this.tab = DIR;
		else if(uses_sig())
			this.tab = SIG;
		else
			this.tab = TOG;
	}


	/* Interaction
	-------------- */
	static var tab_height = 16;
	static var channel_length = 14;
	static var channel_width = 4;
 	static var channel_height = 3;


	public function handle_internal_interaction(game:Main) {
		if(this.module == null)
			return;

		// Tab hover/changing handling
		var tab_width = 19;
		var tab_height = 17;
		if(Geom.inbox(Mouse.x, Mouse.y, this.x, this.y, 64, tab_height)) {
			is_hovering_tab = true;
			// First check box hit for current tab (as it is the largest)
			var dir_x = 0;
			var sig_x = 15;
			var tog_x = 30;
			var rot_x = 45;
			var cur_tab_x = this.x + switch(tab) {
				case DIR: dir_x;
				case SIG: sig_x;
				case TOG: tog_x;
				case ROT: rot_x;
			}
			if(Geom.inbox(Mouse.x, Mouse.y, cur_tab_x, this.y, tab_width, tab_height))
				hovered_tab = tab;
			// Otherwise, do tabs in order (excluding cur tab)
			else {
				if(tab != DIR && Geom.inbox(Mouse.x, Mouse.y, this.x+dir_x, this.y, tab_width, tab_height))
					hovered_tab = DIR;
				else if(tab != SIG && Geom.inbox(Mouse.x, Mouse.y, this.x+sig_x, this.y, tab_width, tab_height))
					hovered_tab = SIG;
				else if(tab != TOG && Geom.inbox(Mouse.x, Mouse.y, this.x+tog_x, this.y, tab_width, tab_height))
					hovered_tab = TOG;
				else if(tab != ROT && Geom.inbox(Mouse.x, Mouse.y, this.x+rot_x, this.y, tab_width, tab_height))
					hovered_tab = ROT;
			}
			// Register click for tab-change
			if(hovered_tab != tab && Mouse.leftreleased()) {
				tab = hovered_tab;
			}
		}

		// Settings handling
 		else {
			switch(tab) {
				// DIR
				case DIR: {
					if(Mouse.leftreleased()) {
						// Check if clicked dir
						var hovering_dir = hovering_dir_button();
						if(hovering_dir != NODIR) {
							this.module.toggle_dir_setting_status(hovering_dir);
						}
					}
				}
				// SIG
				case SIG: {
					var channel_x = this.x + 4;
					var channel_y = this.y + 22;
					this.hovering_channel = get_channel_hover_index(channel_x, channel_y, channel_length, channel_width, channel_height);
					// If hovering a channel and mouse released, select the channel
					if(this.hovering_channel >= 0 && Mouse.leftreleased()) {
						Signal_Manager.set_channel_for_module(this.module, this.hovering_channel, game.signal_manager);
					}
				}
				default: null;
			}
		}
	}

	function hovering_dir_button():Direction {
		var mx = Mouse.x - this.x;
		var my = Mouse.y - this.y;

		var cx = 32; // Center x
		var cy = 26 + tab_height + 1; // Center y

		var rot_point = rotate_about(mx, my, cx, cy, 45);
		var button_bb_x = 14;
		var button_bb_y = 25;
		var button_bb_length = 36;

		if(Geom.inbox(rot_point.x, rot_point.y, button_bb_x, button_bb_y, button_bb_length, button_bb_length)) {
			var left_side = rot_point.x <= cx;
			var up_side = rot_point.y <= cy;
			if(left_side) {
				if(up_side)
					return LEFT;
				return DOWN;
			}
			if(up_side)
				return UP;
			return RIGHT;
		}
		
		return NODIR;
	}

	function rotate_about(x:Int, y:Int, cx: Int, cy: Int, angle: Float):Main.Point {
		var s = Geom.sin(angle);
		var c = Geom.cos(angle);

		// Translate point back to origin:
		x -= cx;
		y -= cy;

		// Rotate point
		var x_temp = Math.round(x * c - y * s);
		var y_temp = Math.round(x * s + y * c);

		// translate point back:
		x = x_temp + cx;
		y = y_temp + cy;

		return { x:x, y:y };
	}

	function get_channel_hover_index(x_start:Int, y_start:Int, length:Int, width: Int, height: Int):Int {
		var mx = Mouse.x - x_start;
		var my = Mouse.y - y_start;

		if(mx < 0 || mx >= length*width || my < 0 || my >= length*height)
			return -1;
		return Std.int(mx/length) + (width * Std.int(my/length));
	}
	function index_to_channel_point(index: Int, x_start:Int, y_start:Int, length:Int, width: Int):Main.Point {
		return {
			x: x_start + (index%width)*length,
			y: y_start + Std.int(index/width)*length,
		}
	}



	/* Rendering
	------------ */
	static var channel_outline_selected = 0x585761;
	static var channel_outline_hover = 0xb3b2a6;

	public function draw_tooltip() {
		if(this.module == null)
			return;

		// Determine proper sprite for each tab 
		var dir_enabled = uses_dirs();
		var sig_enabled = uses_sig();
		var dir_sprite = Tooltip_Sheet.dir_tab_disabled + (dir_enabled ? 2 : 0) - (is_hovering_tab && hovered_tab == DIR ? 1 : 0);
		var sig_sprite = Tooltip_Sheet.sig_tab_disabled + (sig_enabled ? 2 : 0) - (is_hovering_tab && hovered_tab == SIG ? 1 : 0); 
		var tog_sprite = is_hovering_tab && hovered_tab == TOG ? Tooltip_Sheet.tog_tab_hover : Tooltip_Sheet.tog_tab;
		var rot_sprite = is_hovering_tab && hovered_tab == ROT ? Tooltip_Sheet.rot_tab_hover : Tooltip_Sheet.rot_tab;
		// Draw tooltip box relative to which tab is open
		switch(this.tab) {
			/* DIR
			------ */
			case DIR: {
				// Draw other tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, rot_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, tog_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, sig_sprite);
				// Draw main
				if(dir_enabled) {
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_enabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_main);
					var hovering_dir = hovering_dir_button();
					if(!module.get_dir_setting_status(UP)) {
						var up_setting = this.module.get_dir_setting_status(UP);
						if(hovering_dir == UP) {
							Gfx.imagealpha = up_setting ? 0.25 : 0.5;
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_up_disabled);
							Gfx.imagealpha = 1;
						}
						else if(!up_setting) {
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_up_disabled);
						}
					}
					if(!module.get_dir_setting_status(DOWN)) {
						var down_setting = this.module.get_dir_setting_status(DOWN);
						if(hovering_dir == DOWN) {
							Gfx.imagealpha = down_setting ? 0.25 : 0.5;
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_down_disabled);
							Gfx.imagealpha = 1;
						}
						else if(!down_setting) {
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_down_disabled);
						}
					}
					if(!module.get_dir_setting_status(RIGHT)) {
						var right_setting = this.module.get_dir_setting_status(RIGHT);
						if(hovering_dir == RIGHT) {
							Gfx.imagealpha = right_setting ? 0.25 : 0.5;
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_right_disabled);
							Gfx.imagealpha = 1;
						}
						else if(!right_setting) {
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_right_disabled);
						}					}
					if(!module.get_dir_setting_status(LEFT)) {
						var left_setting = this.module.get_dir_setting_status(LEFT);
						if(hovering_dir == LEFT) {
							Gfx.imagealpha = left_setting ? 0.25 : 0.5;
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_left_disabled);
							Gfx.imagealpha = 1;
						}
						else if(!left_setting) {
							Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_left_disabled);
						}
					}
				}
				else {
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_main);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_up_disabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_down_disabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_right_disabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.dir_left_disabled);
				}
				// Draw cur tab
				Gfx.drawtile(x, y, tooltip_sheet_name, dir_sprite);
			}
			/* SIG
			------ */
			case SIG: {
				// Draw other tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, rot_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, tog_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, dir_sprite);
				// Draw main
				if(sig_enabled) {
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_enabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.sig_main);
					var channel_x = this.x + 4;
					var channel_y = this.y + 22;
					// Outline hovered cell, if hover != selected and is greater than 0
					if(this.hovering_channel >= 0) {
						var hovering_point = index_to_channel_point(this.hovering_channel, channel_x, channel_y, channel_length, channel_width);
						Gfx.drawbox(hovering_point.x, hovering_point.y, channel_length, channel_length, channel_outline_hover);
					}
					var cur_channel = Signal_Manager.get_channel_from_module(this.module);
					if(cur_channel < 0) {
						trace("Tooltip.draw_tooltip.SIG: Could not get channel from module");
					}
					else {
						var selected_point = index_to_channel_point(cur_channel, channel_x, channel_y, channel_length, channel_width);
						Gfx.drawbox(selected_point.x, selected_point.y, channel_length, channel_length, channel_outline_selected);
					}
				}
				else {
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
					Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.sig_main);
				}
				// Draw cur tab
				Gfx.drawtile(x, y, tooltip_sheet_name, sig_sprite);
			}
			case TOG: {
				// Draw other tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, rot_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, sig_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, dir_sprite);
				// Draw main
				Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
				// Draw cur tab
				Gfx.drawtile(x, y, tooltip_sheet_name, tog_sprite);
			}
			case ROT: {
				// Draw other tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, tog_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, sig_sprite);
				Gfx.drawtile(x, y, tooltip_sheet_name, dir_sprite);
				// Draw main
				Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
				// Draw cur tab
				Gfx.drawtile(x, y, tooltip_sheet_name, rot_sprite);
			}
		}

		// Reset tab hover
		is_hovering_tab = false;
	}

	// Helpers
	public function is_showing() {
		return this.module != null;
	}

	public function uses_dirs(?cur_module:Wire_Module) {
		return Std.is(cur_module != null ? cur_module : this.module, Modules.Diode_Module);
	}

	public function uses_sig(?cur_module:Wire_Module) {
		var m = cur_module != null ? cur_module : this.module;
		return Std.is(m, Modules.Emittor_Module) || Std.is(m, Modules.Reciever_Module);
	}

	public function hovering() {
		return is_showing() && Geom.inbox(Mouse.x, Mouse.y, this.x, this.y, 65, 65);
	}
}