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
	var tog_tab_hover			= 4;
	var tog_tab 				= 5;
	var rot_tab_hover			= 6;
	var rot_tab					= 7;
	var bg_disabled				= 8;
	var bg_enabled	     		= 9;
	var dir_main				= 10;
	var dir_up_disabled			= 11;
	var dir_down_disabled 		= 12;
	var dir_left_disabled		= 13;
	var dir_right_disabled		= 14;
}


enum Tab {
	DIR;
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
	var hovering_dir : Direction;

	// Constructor
	public function new() {
		this.tab = DIR;

		this.x = 0;
		this.y = 0;
		this.module = null;
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
		else
			this.tab = TOG;
	}


	// Interaction
	static var tab_height = 16;
	public function handle_internal_interaction() {
		if(this.module == null)
			return;

		if(Mouse.leftreleased()) {
			// Check if clicked dir
			var hovering_dir = hovering_dir_button();
			if(hovering_dir != NODIR) {
				this.module.toggle_dir_setting_status(hovering_dir);
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



	// Rendering
	public function draw_tooltip() {
		if(this.module == null)
			return;

		// Draw tooltip box relative to which tab is open
		var dirs_enabled = uses_dirs();
		switch(this.tab) {
			case DIR: {
				// Draw other tabs
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.tog_tab_enabled);
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.rot_tab_enabled);
				// Draw main
				if(dirs_enabled) {
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
				Gfx.drawtile(x, y, tooltip_sheet_name, dirs_enabled ? Tooltip_Sheet.dir_tab_enabled : Tooltip_Sheet.dir_tab_disabled);
			}
			case TOG: {
				// Draw other tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, dirs_enabled ? Tooltip_Sheet.dir_tab_enabled : Tooltip_Sheet.dir_tab_disabled);
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.rot_tab_enabled);
				// Draw main
				Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
				// Draw cur tab
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.tog_tab_enabled);
			}
			case ROT: {
				// Draw tabs
				Gfx.drawtile(x, y, tooltip_sheet_name, dirs_enabled ? Tooltip_Sheet.dir_tab_enabled : Tooltip_Sheet.dir_tab_disabled);
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.tog_tab_enabled);
				// Draw main
				Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.bg_disabled);
				// Draw cur tab
				// Gfx.drawtile(x, y, tooltip_sheet_name, Tooltip_Sheet.rot_tab_enabled);
			}
		}
	}

	// Helpers
	public function is_showing() {
		return this.module != null;
	}

	public function uses_dirs(?cur_module:Wire_Module) {
		return Std.is(cur_module != null ? cur_module : this.module, Modules.Diode_Module);
	}

	public function hovering() {
		return is_showing() && Geom.inbox(Mouse.x, Mouse.y, this.x, this.y, 65, 65);
	}

}