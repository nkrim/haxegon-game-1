import haxegon.*;
import Wire.*;

class Main {
	function init(){
	  	Text.font = "Kankin";
	  	Text.size = 32;
	  	Gfx.clearcolor = 0x222222;

	  	wire_grid = [for (r in 0...grid_height) [for (c in 0...grid_width) Wire.init_wire_module()]];

	  	// Init sheet loading
	  	Wire.load_wire_spritesheet();
	}
  
	function update() {
	  	Text.display(0, 0, "Hello, Sailor!");
	  	draw_wire_grid();
	}

	var wire_grid : Array<Array<Wire.Wire_Module>>;

	var grid_width = 8;
  	var grid_height = 8;
  	var grid_x = 100;
  	var grid_y = 100;

  	public static var module_side_length = 64;
  	public static var half_module_length = 32;

  	var outline_color = 0x52515c;



  	function draw_wire_grid() {
  		// Render in reverse order to preserve overlapping pixels
  		var r = grid_height;
  		while((--r) >= 0) {
  			var c = grid_width-1;
  			while((--c) >= 0) {
  				var wm = wire_grid[r][c];
	  			Wire.draw_wire_module(grid_x + c*module_side_length, grid_y + r*module_side_length, wm, false);
	  			trace('$r, $c');
  			}
  		}
  	}
}