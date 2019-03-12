package;


import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

		}

		if (rootPath == null) {

			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif console
			rootPath = lime.system.System.applicationDirectory;
			#elseif (sys && windows && !cs)
			rootPath = FileSystem.absolutePath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) Sys.programPath () #else Sys.executablePath () #end)) + "/";
			#else
			rootPath = "";
			#end

		}

		Assets.defaultRootPath = rootPath;

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__data_fonts_kankin_ttf);
		
		#end

		var data, manifest, library;

		#if kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":null,"assets":"aoy4:sizei55940y4:typey4:FONTy9:classNamey30:__ASSET__data_fonts_kankin_ttfy2:idy25:data%2Ffonts%2FKankin.ttfy7:preloadtgoy4:pathy34:data%2Fgraphics%2Fmodule_sheet.pngR0i9656R1y5:IMAGER5R9R7tgoR8y35:data%2Fgraphics%2Ftooltip_sheet.pngR0i4056R1R10R5R11R7tgoR8y34:data%2Fhow%20to%20add%20assets.txtR0i6838R1y4:TEXTR5R12R7tgoR8y15:data%2Ficon.pngR0i143966R1R10R5R14R7tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

		#end

	}


}


#if kha

null

#else

#if !display
#if flash

@:keep @:bind #if display private #end class __ASSET__data_fonts_kankin_ttf extends null { }
@:keep @:bind #if display private #end class __ASSET__data_graphics_module_sheet_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__data_graphics_tooltip_sheet_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__data_how_to_add_assets_txt extends null { }
@:keep @:bind #if display private #end class __ASSET__data_icon_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:font("bin/html5/obj/webfont/Kankin.ttf") #if display private #end class __ASSET__data_fonts_kankin_ttf extends lime.text.Font {}
@:keep @:image("data/graphics/module_sheet.png") #if display private #end class __ASSET__data_graphics_module_sheet_png extends lime.graphics.Image {}
@:keep @:image("data/graphics/tooltip_sheet.png") #if display private #end class __ASSET__data_graphics_tooltip_sheet_png extends lime.graphics.Image {}
@:keep @:file("data/how to add assets.txt") #if display private #end class __ASSET__data_how_to_add_assets_txt extends haxe.io.Bytes {}
@:keep @:image("data/icon.png") #if display private #end class __ASSET__data_icon_png extends lime.graphics.Image {}
@:keep @:file("") #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__data_fonts_kankin_ttf') #if display private #end class __ASSET__data_fonts_kankin_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "data/fonts/Kankin"; #else ascender = 750; descender = -250; height = 1075; numGlyphs = 352; underlinePosition = -100; underlineThickness = 50; unitsPerEM = 1000; #end name = "Kankin"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__data_fonts_kankin_ttf') #if display private #end class __ASSET__OPENFL__data_fonts_kankin_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__data_fonts_kankin_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__data_fonts_kankin_ttf') #if display private #end class __ASSET__OPENFL__data_fonts_kankin_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__data_fonts_kankin_ttf ()); super (); }}

#end

#end
#end

#end
