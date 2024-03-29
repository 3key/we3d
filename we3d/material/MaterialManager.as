package we3d.material 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import we3d.we3d;
	import we3d.filter.ZBuffer;
	import we3d.rasterizer.NativeFlat;
	import we3d.rasterizer.NativeFlatCurved;
	import we3d.rasterizer.NativeFlatLight;
	import we3d.rasterizer.NativeFlatWire;
	import we3d.rasterizer.NativeFlatWireLight;
	import we3d.rasterizer.NativeTX;
	import we3d.rasterizer.NativeTXLight;
	import we3d.rasterizer.NativeTXWire;
	import we3d.rasterizer.NativeTXWireLight;
	import we3d.rasterizer.NativeWire;
	import we3d.rasterizer.Rasterizer;
	import we3d.rasterizer.RasterizerLight;
	import we3d.rasterizer.RasterizerZBuffer;
	import we3d.rasterizer.RasterizerZBufferLight;
	import we3d.rasterizer.ScanlineFlat;
	import we3d.rasterizer.ScanlineFlatLight;
	import we3d.rasterizer.ScanlineFlatLightZB;
	import we3d.rasterizer.ScanlineFlatWire;
	import we3d.rasterizer.ScanlineFlatWireLight;
	import we3d.rasterizer.ScanlineFlatWireLightZB;
	import we3d.rasterizer.ScanlineFlatWireZB;
	import we3d.rasterizer.ScanlineFlatZB;
	import we3d.rasterizer.ScanlineTX;
	import we3d.rasterizer.ScanlineTX32;
	import we3d.rasterizer.ScanlineTX32Light;
	import we3d.rasterizer.ScanlineTX32Wire;
	import we3d.rasterizer.ScanlineTX32WireLight;
	import we3d.rasterizer.ScanlineTXLight;
	import we3d.rasterizer.ScanlineTXWire;
	import we3d.rasterizer.ScanlineTXWireLight;
	import we3d.rasterizer.ScanlineTXZB;
	import we3d.rasterizer.ScanlineTXZB32;
	import we3d.rasterizer.ScanlineTXZB32Light;
	import we3d.rasterizer.ScanlineTXZB32Wire;
	import we3d.rasterizer.ScanlineTXZB32WireLight;
	import we3d.rasterizer.ScanlineTXZBLight;
	import we3d.rasterizer.ScanlineTXZBWire;
	import we3d.rasterizer.ScanlineTXZBWireLight;
	import we3d.rasterizer.ScanlineWire;
	import we3d.scene.LightGlobals;
	import we3d.ui.Console;
	use namespace we3d;
	
	/**
	* The MaterialManager class is a helper to create and setup Materials
	*/
	public class MaterialManager extends EventDispatcher
	{
		public function MaterialManager () {}
		
		private var _loadingBitmap:BitmapData=new BitmapData(128,128,false,0);
		public function set loadingBitmap (bmp:BitmapData) :void {
			_loadingBitmap = bmp;
		}
		
		private var loadBitmaps:Object={};
		we3d function loadImage (img:String, sf:Surface) :void 
		{
			if( img != "" && img != "null") {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, imgComplete );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imgError );
				var req:URLRequest = new URLRequest(img);
				loadBitmaps[img] = sf;
				loader.load( req );
			}
		}
		
		private function imgComplete (e:Event) :void {
			var loader:Loader = LoaderInfo(e.target).loader;
			var path:String = loader.contentLoaderInfo.url;
			
			var bmp:BitmapData;
			if( loader.contentLoaderInfo.contentType == "application/x-shockwave-flash" ) {
				var sp:Sprite = Sprite(loader.content);
				bmp = new BitmapData(sp.width, sp.height, true, 0);
				bmp.draw(sp);
			}else{
				bmp = Bitmap(loader.content).bitmapData;
			}
			var sf:Surface = Surface(loadBitmaps[path]);
			
			BitmapAttributes(sf.attributes).texture = bmp;
			
			if(bmp.transparent) {
				if(sf.rasterizer is ScanlineTX) {
					sf.rasterizer = scanlineTX32;
				}else if(sf.rasterizer is ScanlineTXLight) {
						sf.rasterizer = scanlineTX32Light;
				}else if(sf.rasterizer is ScanlineTXWire) {
					sf.rasterizer = scanlineTX32Wire;
				}else if(sf.rasterizer is ScanlineTXWireLight) {
					sf.rasterizer = scanlineTX32WireLight;
				}
				else if(sf.rasterizer is ScanlineTXZB) {
					sf.rasterizer = new ScanlineTXZB32(ScanlineTXZB(sf.rasterizer).zBuffer);
				}else if(sf.rasterizer is ScanlineTXZBLight) {
					sf.rasterizer = new ScanlineTXZB32Light(ScanlineTXZBLight(sf.rasterizer).zBuffer);
				}else if(sf.rasterizer is ScanlineTXZBWire) {
					sf.rasterizer = new ScanlineTXZB32Wire(ScanlineTXZBWire(sf.rasterizer).zBuffer);
				}else if(sf.rasterizer is ScanlineTXZBWireLight) {
					sf.rasterizer = new ScanlineTXZB32WireLight(ScanlineTXZBWireLight(sf.rasterizer).zBuffer);
				}
			}
			
			dispatchEvent( new Event(Event.CHANGE ) );
		}
		
		private function imgError (e:Event) :void {
			Console.log("MatMgr Image load error: " + e);
		} 
		
		/**
		* Contains all materials created with createMaterial()
		*/
		public var materials:Array = [];
		
		private static var scanlineWire:		ScanlineWire 			= new ScanlineWire;
		private static var scanlineFlat:		ScanlineFlat 			= new ScanlineFlat;
		private static var scanlineFlatWire:	ScanlineFlatWire 		= new ScanlineFlatWire;
		private static var scanlineFlatLight:	ScanlineFlatLight 		= new ScanlineFlatLight;
		private static var scanlineFlatWireLight:ScanlineFlatWireLight 	= new ScanlineFlatWireLight;
		private static var scanlineTX:			ScanlineTX 				= new ScanlineTX;
		private static var scanlineTXWire:		ScanlineTXWire 			= new ScanlineTXWire;
		private static var scanlineTXLight:		ScanlineTXLight 		= new ScanlineTXLight;
		private static var scanlineTXWireLight:	ScanlineTXWireLight 	= new ScanlineTXWireLight;
		private static var scanlineTX32:		ScanlineTX32 			= new ScanlineTX32;
		private static var scanlineTX32Wire:	ScanlineTX32Wire 		= new ScanlineTX32Wire;
		private static var scanlineTX32Light:	ScanlineTX32Light 		= new ScanlineTX32Light;
		private static var scanlineTX32WireLight:ScanlineTX32WireLight 	= new ScanlineTX32WireLight;
		
		private static var nativeFlat:			NativeFlat 				= new NativeFlat;
		private static var nativeWire:			NativeWire 				= new NativeWire;
		private static var nativeFlatWire:		NativeFlatWire 			= new NativeFlatWire;
		private static var nativeFlatLight:		NativeFlatLight 		= new NativeFlatLight;
		private static var nativeFlatWireLight:	NativeFlatWireLight 	= new NativeFlatWireLight;
		private static var nativeTX:			NativeTX 				= new NativeTX;
		private static var nativeTXWire:		NativeTXWire			= new NativeTXWire;
		private static var nativeTXLight:		NativeTXLight			= new NativeTXLight;
		private static var nativeTXWireLight:	NativeTXWireLight		= new NativeTXWireLight;
		private static var nativeFlatCurved:	NativeFlatCurved		= new NativeFlatCurved;
		
		private var materialsByName:Dictionary = new Dictionary(true);
		
		/**
		* Returns a material in the material list
		*/
		public function getMaterialAt (id:int) :Surface {
			return materials[id];
		}
		/**
		* Returns a material by name if it had a name property
		*/
		public function getMaterialByName (name:String) :Surface {
			return materialsByName[name];
		}
		public function getMaterialName (sf:Surface) :String {
			if(materialsByName != null) {
				for(var name:String in materialsByName) {
					if( materialsByName[name] === sf ) {
						return name;
					}
				}
			}
			return "";
		}
		public function getMaterialId (sf:Surface) :int {
			if(materials != null) {
				return materials.indexOf(sf);
			}
			return -1;
		}
		/**
		* Returns the property object of a material wich can be passed to createMaterial or setupMaterial
		*/
		public function getMaterialProperties (sf:Surface) :Object {
			
			var r:Object = { hideBackfaces: sf.hideBackfaces/*, shared: sf.shared*/};
			var s:String;
			
			s = getMaterialName( sf );
			if(s != "") r.name = s;
			var id:int = getMaterialId( sf );
			if(id != -1) r.id = id;
			
			
			if(sf.attributes is BitmapAttributes) {
				var batb:BitmapAttributes = BitmapAttributes(sf.attributes);
				
				// Texture
				r.bitmap = batb.texture;
				r.color = batb.color;
				r.alpha = batb.alpha;
				r.smooth = batb.smooth;
				r.repeat = batb.repeat;
				
				if(sf.rasterizer is Rasterizer || sf.rasterizer is RasterizerLight) {
					// Scanline Texture
					r.scanline = true;
					
					if(sf.rasterizer is ScanlineTX32 || sf.rasterizer is ScanlineTXZB32) {
						r.transparent = true;
					}
					
					if(sf.rasterizer is RasterizerZBuffer) {
						r.zbuffer = RasterizerZBuffer(sf.rasterizer).zBuffer || true;
					}else if( sf.rasterizer is RasterizerZBufferLight) {
						r.zbuffer = RasterizerZBufferLight(sf.rasterizer).zBuffer || true;
					}
				}
				else{
					// Native Texture
					r.scanline = false;
				}
				
				if(sf.attributes is BitmapWireLightAttributes) {
					var bmpwla:BitmapWireLightAttributes = BitmapWireLightAttributes(sf.attributes);
					r.luminosity = bmpwla.luminosity;
					r.diffuse = bmpwla.diffuse;
					r.lightGlobals = bmpwla.lightGlobals;
					r.lighting = true;
					r.lineColor = bmpwla.lineColor;
					r.lineAlpha = bmpwla.lineAlpha;
					r.lineStyle = bmpwla.lineStyle;
				}
				else if(sf.attributes is BitmapLightAttributes) {
					var bmpla:BitmapLightAttributes = BitmapLightAttributes(sf.attributes);
					r.luminosity = bmpla.luminosity;
					r.diffuse = bmpla.diffuse;
					r.lightGlobals = bmpla.lightGlobals;
					r.lighting = true;
				}
				else if(sf.attributes is BitmapWireAttributes) {
					var bmpwa:BitmapWireAttributes = BitmapWireAttributes(sf.attributes);
					r.lineColor = bmpwa.lineColor;
					r.lineAlpha = bmpwa.lineAlpha;
					r.lineStyle = bmpwa.lineStyle;
				}
				
			}
			else {
				
				var flatAtb:FlatAttributes;
				var flatWireAtb:FlatWireAttributes;
				var flatWireLightAtb:FlatWireLightAttributes;
				
				// Flat
				if((sf.rasterizer is Rasterizer) || (sf.rasterizer is RasterizerLight)) 
				{
					// Software
					r.scanline = true;
					
					if(sf.rasterizer is RasterizerZBuffer) {
						r.zbuffer = RasterizerZBuffer(sf.rasterizer).zBuffer || true;
					}else if(sf.rasterizer is RasterizerZBufferLight) {
						r.zbuffer = RasterizerZBufferLight(sf.rasterizer).zBuffer || true;				
					}
					
					flatAtb = FlatAttributes(sf.attributes);
					r.color = flatAtb.color;
					r.alpha = flatAtb.alpha;
					
					if(sf.attributes is FlatWireLightAttributes) {
						flatWireLightAtb = FlatWireLightAttributes( sf.attributes );
						r.lineColor = flatWireLightAtb.lineColor;
						r.lineAlpha = flatWireLightAtb.lineAlpha;
						r.lineStyle = flatWireLightAtb.lineStyle;
						r.lightGlobals = flatWireLightAtb.lightGlobals;
						r.luminosity = flatWireLightAtb.luminosity;
						r.diffuse = flatWireLightAtb.diffuse;
						r.lighting = true;
					}
					else if(sf.attributes is FlatLightAttributes) {
						var lightAtb:FlatLightAttributes = FlatLightAttributes(sf.attributes);
						r.lightGlobals = lightAtb.lightGlobals;
						r.luminosity = lightAtb.luminosity;
						r.diffuse = lightAtb.diffuse;
						r.lighting = true;
					}
					else if(sf.attributes is FlatWireAttributes) {
						flatWireAtb = FlatWireAttributes( sf.attributes );
						r.lineColor = flatWireAtb.lineColor;
						r.lineAlpha = flatWireAtb.lineAlpha;
						r.lineStyle = flatWireAtb.lineStyle;
					}
				}
				else
				{
					// Native
					r.scanline = false;
					
					if(sf.rasterizer is NativeFlat) {
						flatAtb = FlatAttributes(sf.attributes);
						r.color = flatAtb.color;
						r.alpha = flatAtb.alpha;
					}
					else if(sf.rasterizer is NativeWire) {
						var wireAtb:WireAttributes = WireAttributes(sf.attributes);
						r.lineColor = wireAtb.color;
						r.lineAlpha = wireAtb.alpha;
						r.lineStyle = wireAtb.lineStyle;
					}
					else if(sf.rasterizer is NativeFlatLight) {
						var flatLightAtb:FlatLightAttributes = FlatLightAttributes(sf.attributes);
						r.color = flatLightAtb.color;
						r.alpha = flatLightAtb.alpha;
						r.lighting = true;
						r.lightGlobals = flatLightAtb.lightGlobals;
						r.luminosity = flatLightAtb.luminosity;
						r.diffuse = flatLightAtb.diffuse;
					}
					else if(sf.rasterizer is NativeFlatWire) {
						flatWireAtb = FlatWireAttributes(sf.attributes);
						r.color = flatWireAtb.color;
						r.alpha = flatWireAtb.alpha;
						r.lineStyle = flatWireAtb.lineStyle;
						r.lineColor = flatWireAtb.lineColor;
						r.lineAlpha = flatWireAtb.lineAlpha;
					}
					else if(sf.rasterizer is NativeFlatWireLight) {
						flatWireLightAtb = FlatWireLightAttributes(sf.attributes);
						r.color = flatWireLightAtb.color;
						r.alpha = flatWireLightAtb.alpha;
						r.lineStyle = flatWireLightAtb.lineStyle;
						r.lineColor = flatWireLightAtb.lineColor;
						r.lineAlpha = flatWireLightAtb.lineAlpha;
						r.lighting = true;
						r.lightGlobals = flatWireLightAtb.lightGlobals;
						r.luminosity = flatWireLightAtb.luminosity;
						r.diffuse = flatWireLightAtb.diffuse;
					}
					else if(sf.rasterizer is NativeFlatCurved) {
						var flatAtb2:FlatAttributes = FlatAttributes(sf.attributes);
						r.curved = true;
						r.color = flatAtb2.color;
						r.alpha = flatAtb2.alpha;
					}
				}
			}
			
			return r;
		}
		
		/**
		* Creates a material and controls the appearance with the propObj
		* 
		* <code><pre>
		* 
		* propObj {
		* 
		* 
		*  // General Properties
		* 
		*  .name				if set, the material is also stored by name
		* 
		*  .id					if set to a number, the material is inserted at this index of the material list
		* 
		* .hideBackfaces		if true polygons are single sided else double sided
		* 
		* 
		*  // Default Surface Properties
		* 
		*  .color				the color of the material, if null, the WireAttributes is assigned
		* 
		*  .alpha				alpha transparency (0-1)
		* 
		*  .lineStyle			the thickness of outlines in pixel
		* 
		*  .lineColor			the line color if polygons should have outlines
		* 
		*  .lineAlpha			alpha of outlines (0-1)
		* 
		* 
		* 
		*  // Lighting properties
		* 
		*  .lighting			true if the material can use lighting
		* 
		*  .lightGlobals		if lighting is true lightGlobals have to be a LightGlobals instance
		* 
		*  .luminosity			lighting property for self lighting (0-1 or higher)
		* 
		*  .diffuse				lighting property for diffuse light reflection (0-1 or higher)
		* 
		* 
		* 
		* 	// To use Texturing, set bitmap to one of the bitmap types
		* 
		* 	.bitmap				Bitmap, BitmapData or Sprite
		*   
		*   .transparent		If transparent is set the material uses a 32 Bit texture rasterizer
		* 
		* 
		* 
		*  // The following properties control the Rasterizer used in the Material
		* 
		*  .scanline			if true, polygons with the new material are rendered with one of the AS3 software rasterizers,
		* 						if scanline is unset or false, the native rasterizer of the flash player is used
		* 
		*  .zbuffer				to enable depth sorting with pixel precision, set the zbuffer to a ZBuffer filter, 
		* 						ZBuffer can only be used with scanline enabled
		*   
		*  .wireframe			if true, the material uses a rasterizer wich draws only lines
		* 
		*  .curved				if true, the rasterizer can draw curved points, currently only with native curves
		* 
		* }
		* </pre></code>
		* 
		* @param	propObj
		* @return
		*/
		public function createMaterial (propObj:Object) :Surface {
			
			var sf:Surface = new Surface();
			
			setupMaterial(sf, propObj);
			
			if(typeof(propObj.id)=="number") {
				materials.splice(propObj.id, 0, sf);
			}else{
				materials.push(sf);
			}
			
			return sf;
		}
		
		/**
		* Controls the appearance of a material
		* @param	sf the Material to setup
		* @param	propObj an object with properties like color, scanline, zbuffer etc.
		*/
		public function setupMaterial (sf:Surface, propObj:Object) :void {
			
			if(propObj.name is String) materialsByName[propObj.name] = sf;
			if(propObj.hideBackfaces != null) {
				sf.hideBackfaces = propObj.hideBackfaces;
			}
			
			var w:Boolean=false;
			var lighting:Boolean = propObj.lighting && propObj.lightGlobals is LightGlobals;
			
			var bmpWireLightAtb:BitmapWireLightAttributes;
			var bmpatb:BitmapAttributes;
			var bmpWireAtb:BitmapWireAttributes;
			var bmpLightAtb:BitmapLightAttributes;
			
			var wireAtb:WireAttributes;
			var flatAtb:FlatAttributes;
			var flatWireLightAtb:FlatWireLightAttributes;
			var flatWireAtb:FlatWireAttributes;
			var flatLightAtb:FlatLightAttributes;
			
			if(propObj.bitmap && propObj.bitmap != "") 
			{
				if(sf.attributes is BitmapWireLightAttributes) {
					bmpWireLightAtb = BitmapWireLightAttributes(sf.attributes);
				}
				else if(sf.attributes is BitmapWireAttributes) {
					bmpWireAtb = BitmapWireAttributes( sf.attributes );
					bmpWireLightAtb = new BitmapWireLightAttributes(	bmpWireAtb.texture, 
																		bmpWireAtb.lineColor,   
																		bmpWireAtb.lineAlpha, 
																		bmpWireAtb.lineStyle);
				}
				else if(sf.attributes is BitmapLightAttributes) {
					bmpLightAtb = BitmapLightAttributes( sf.attributes );
					bmpWireLightAtb = new BitmapWireLightAttributes(bmpLightAtb.texture, null,null,null, bmpLightAtb.luminosity, bmpLightAtb.diffuse, bmpLightAtb.lightGlobals);
				}
				else if(sf.attributes is BitmapAttributes) {
					bmpatb = BitmapAttributes(sf.attributes);
					bmpWireLightAtb = new BitmapWireLightAttributes(bmpatb.texture);
				}
				else{
					bmpWireLightAtb = new BitmapWireLightAttributes();
				}
				
				if(propObj.bitmap is Bitmap) {
					bmpWireLightAtb.texture = propObj.bitmap.bitmapData;
				}else if(propObj.bitmap is BitmapData) {
					bmpWireLightAtb.texture = propObj.bitmap;
				}else if(propObj.bitmap is Sprite) {	// cast sprite to bitmap
					var sp:Sprite = propObj.bitmap;
					var bmp:BitmapData = new BitmapData(sp.width, sp.height, true, 0);
					bmp.draw(sp);
					bmpWireLightAtb.texture = bmp;
				}else if(propObj.bitmap is String) {
					bmpWireLightAtb.texture = this._loadingBitmap;
					loadImage( propObj.bitmap, sf );
				}
				
				if(propObj.smooth==true) bmpWireLightAtb.smooth =true;
				else bmpWireLightAtb.smooth = false;
				
				if(propObj.repeat==true) bmpWireLightAtb.repeat =true;
				else bmpWireLightAtb.repeat = false;
				
				if( bmpWireLightAtb.texture && bmpWireLightAtb.texture.transparent) {
					propObj.transparent = true;
				}
				
				if(propObj.color is Number) bmpWireLightAtb.color = propObj.color;
				if(propObj.alpha is Number) bmpWireLightAtb.alpha = propObj.alpha;
				
				if(propObj.lineColor is Number) {
					bmpWireLightAtb.lineColor = propObj.lineColor;
					w = true;
				}
				if(propObj.lineStyle is Number) {
					bmpWireLightAtb.lineStyle = propObj.lineStyle;
					w = true;
				}
				if(propObj.lineAlpha is Number) {
					bmpWireLightAtb.lineAlpha = propObj.lineAlpha;
					w = true;
				}
				
				if(propObj.luminosity is Number) bmpWireLightAtb.luminosity = propObj.luminosity;
				if(propObj.diffuse is Number) bmpWireLightAtb.diffuse = propObj.diffuse;
				if(propObj.lightGlobals is LightGlobals) bmpWireLightAtb.lightGlobals = propObj.lightGlobals;
				
				if(lighting) {
					if(w) {
						sf.attributes = bmpWireLightAtb;
					}
					else{
						sf.attributes = new BitmapLightAttributes(	bmpWireLightAtb.texture, 
																		bmpWireLightAtb.luminosity, 
																		bmpWireLightAtb.diffuse, 
																		bmpWireLightAtb.lightGlobals);
						
					}
				}else{
					if(w) {
						sf.attributes = new BitmapWireAttributes(bmpWireLightAtb.texture,
																	 bmpWireLightAtb.lineColor,
																	 bmpWireLightAtb.lineAlpha,
																	 bmpWireLightAtb.lineStyle);
						
					}
					else{
						sf.attributes = new BitmapAttributes(bmpWireLightAtb.texture);
					}
				}
				
				if(!propObj.scanline && !propObj.zbuffer) {
					if(lighting) {
						if(w) {
							sf.rasterizer = nativeTXWireLight;
						}else{
							sf.rasterizer = nativeTXLight;
						}
					}
					else{
						// no lighting
						if(w) {
							sf.rasterizer = nativeTXWire;
						}else{
							sf.rasterizer = nativeTX;
						}
					}
				}
				else{
					if(propObj.zbuffer==true) {
						if(propObj.transparent) {
							if(lighting) {
								if(w) {
									sf.rasterizer = new ScanlineTXZB32WireLight(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}else{
									sf.rasterizer = new ScanlineTXZB32Light(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}
							}
							else{
								if(w) {
									sf.rasterizer = new ScanlineTXZB32Wire(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}else{
									sf.rasterizer = new ScanlineTXZB32(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}
							}
						}
						else{
							if(lighting) {
								if(w) {
									sf.rasterizer = new ScanlineTXZBWireLight(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}else{
									sf.rasterizer = new ScanlineTXZBLight(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}
							}
							else{
								if(w) {
									sf.rasterizer = new ScanlineTXZBWire(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}else{
									sf.rasterizer = new ScanlineTXZB(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
								}
							}
						}
					}
					else{
						if(propObj.transparent) {
							if(lighting) {
								if(w) {
									sf.rasterizer = scanlineTX32WireLight;
								}else{
									sf.rasterizer = scanlineTX32Light;
								}
							}
							else{
								if(w) {
									sf.rasterizer = scanlineTX32Wire;
								}else{
									sf.rasterizer = scanlineTX32;
								}
							}
						}else{
							if(lighting) {
								if(w) {
									sf.rasterizer = scanlineTXWireLight;
								}else{
									sf.rasterizer = scanlineTXLight;
								}
							}
							else{
								if(w) {
									sf.rasterizer = scanlineTXWire;
								}else{
									sf.rasterizer = scanlineTX;
								}
							}
						}
					}
				}
				
				var tmp:BitmapAttributes = BitmapAttributes( sf.attributes );
				tmp.color = bmpWireLightAtb.color;
				tmp.alpha = bmpWireLightAtb.alpha;
				tmp.repeat = bmpWireLightAtb.repeat;
				tmp.smooth = bmpWireLightAtb.repeat;
			}
			else if(propObj.wireframe) 
			{
				if(propObj.scanline) {
					sf.rasterizer = scanlineWire;
				}else{
					sf.rasterizer = nativeWire;
				}
				if(sf.attributes is WireAttributes) {
					wireAtb = WireAttributes(sf.attributes);
					wireAtb.color = propObj.lineColor || 0;
					wireAtb.alpha = propObj.lineAlpha || 1;
					wireAtb.lineStyle = propObj.lineStyle || 0;
				}else{
					sf.attributes = new WireAttributes( propObj.lineColor || 0, propObj.lineAlpha || 1, propObj.lineStyle || 0 );
				}
			}
			else if(propObj.curved) 
			{
				sf.rasterizer = nativeFlatCurved;
				if(sf.attributes is FlatAttributes) {
					flatAtb = FlatAttributes(sf.attributes);
					flatAtb.color = propObj.color || 0;
					flatAtb.alpha = propObj.alpha || 1;
				}else{
					sf.attributes = new FlatAttributes( propObj.color || 0, propObj.alpha || 1 );
				}
			}
			else
			{
				var atb:FlatWireLightAttributes;
				
				if(sf.attributes is FlatWireLightAttributes) {
					atb = FlatWireLightAttributes(sf.attributes);
				}
				else if(sf.attributes is FlatLightAttributes) {
					flatLightAtb = FlatLightAttributes(sf.attributes);
					atb = new FlatWireLightAttributes(flatLightAtb.color, flatLightAtb.alpha,0,1,0,flatLightAtb.luminosity, flatLightAtb.diffuse, flatLightAtb.lightGlobals);
				}
				else if(sf.attributes is FlatWireAttributes) {
					flatWireAtb = FlatWireAttributes(sf.attributes);
					atb = new FlatWireLightAttributes(flatWireAtb.color, flatWireAtb.alpha, flatWireAtb.lineColor, flatWireAtb.lineAlpha, flatWireAtb.lineStyle);
				}
				else if(sf.attributes is FlatAttributes) {
					flatAtb = FlatAttributes(sf.attributes);
					atb = new FlatWireLightAttributes(flatAtb.color, flatAtb.alpha);
				}
				else {
					atb = new FlatWireLightAttributes();
				}
				
				if(propObj.color is Number) {
					atb.color = propObj.color;
				}
				if(propObj.alpha is Number) {
					atb.alpha = propObj.alpha;
				}
				
				if(propObj.lineColor is Number) {
					atb.lineColor = propObj.lineColor;
					w = true;
				}
				if(propObj.lineStyle is Number) {
					atb.lineStyle = propObj.lineStyle;
					w = true;
				}
				if(propObj.lineAlpha is Number) {
					atb.lineAlpha = propObj.lineAlpha;
					w = true;
				}
				if(propObj.luminosity is Number) atb.luminosity = propObj.luminosity;
				if(propObj.diffuse is Number) atb.diffuse = propObj.diffuse;
				if(propObj.lightGlobals is LightGlobals) atb.lightGlobals = propObj.lightGlobals;
				
				if(propObj.scanline==true) 
				{
					if(w) { // if wire
						if(lighting) { // if lighting
							sf.attributes = atb;
							if(propObj.zbuffer) {
								sf.rasterizer = new ScanlineFlatWireLightZB(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
							}else{
								sf.rasterizer = scanlineFlatWireLight;
							}
						}
						else{
							sf.attributes = new FlatWireAttributes(atb.color, atb.alpha, atb.lineColor, atb.lineAlpha, atb.lineStyle);
							if(propObj.zbuffer) {
								sf.rasterizer = new ScanlineFlatWireZB(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
							}else{
								sf.rasterizer = scanlineFlatWire;
							}
						}
					}
					else
					{
						if(lighting) {
							sf.attributes = new FlatLightAttributes(atb.color, atb.alpha, atb.luminosity, atb.diffuse, propObj.lightGlobals || null);
							if(propObj.zbuffer) {
								sf.rasterizer = new ScanlineFlatLightZB(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
							}else{
								sf.rasterizer = scanlineFlatLight;
							}	
						}
						else{
							sf.attributes = new FlatAttributes(atb.color, atb.alpha);
							if(propObj.zbuffer) {
								sf.rasterizer = new ScanlineFlatZB(propObj.zbuffer is ZBuffer ? propObj.zbuffer : null);
							}else{
								sf.rasterizer = scanlineFlat;
							}
						}
					}
				}
				else{
					if(w) {
						if(lighting) {
							sf.rasterizer = nativeFlatWireLight;
							sf.attributes = atb;
						}
						else{
							sf.rasterizer = nativeFlatWire;
							sf.attributes = new FlatWireAttributes(atb.color, atb.alpha, atb.lineColor, atb.lineAlpha, atb.lineStyle);
						}
					}
					else{
						if(lighting) {
							sf.rasterizer = nativeFlatLight;
							sf.attributes = new FlatLightAttributes(atb.color, atb.alpha, atb.luminosity, atb.diffuse, propObj.lightGlobals || null);
						}
						else{
							sf.rasterizer = nativeFlat;
							sf.attributes = new FlatAttributes(atb.color, atb.alpha);
						}
					}
					
				}
			}
		}
		
		/**
		* Removes one or more materials from the material list
		* @param	id	the id of the first material to remove
		* @param	count	the count of materials to delete
		*/
		public function removeMaterialAt (id:uint, count:uint=1) :void {
			if(id >= 0 && id<=materials.length-count) {
				
				var del:Array = materials.splice(id, count);
				var L:int = del.length;
				var name:String;
				
				for(var i:int=0; i<L; i++) {
					name = getMaterialName( del[i] );
					if(name != "") {
						removeMaterialByName(name);
					}
				}
			}
		}
		
		/**
		* Remove a material by name
		*/
		public function removeMaterialByName (name:String) :Boolean {
			var mat:* = materialsByName[name];
			if(mat) {
				var id:int = materials.indexOf(mat);
				if(id != -1) {
					materials.splice(id, 1);
					delete materialsByName[name];
					return true;
				}
			}
			return false;
		}
		
	}
}