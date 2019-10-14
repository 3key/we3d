package we3d.loader
{
	import flash.display.Scene;
	import flash.utils.Dictionary;
	
	import we3d.we3d;
	import we3d.animation.EnvelopeChannel;
	import we3d.animation.KeyFrame;
	import we3d.animation.LinearChannel;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.material.BitmapAttributes;
	import we3d.material.MaterialManager;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.scene.MorphFrame;
	import we3d.scene.MorphKeyFrame;
	import we3d.scene.SceneLight;
	import we3d.scene.SceneObject;
	import we3d.scene.SceneObjectBones;
	import we3d.scene.SceneObjectMorph;
	import we3d.scene.SceneParticles;
	import we3d.scene.SceneSpriteF10;
	import we3d.scene.dynamics.ParticleDotRenderer;
	import we3d.view.View3d;
	
	use namespace we3d;
	
	/**
	* XML Scene Export, files can be loaded with WE3DLoader
	*/ 
	public class WE3DExport
	{
		public function WE3DExport() {}
		
		private static var nl:String = "\n";
		private static var tab1:String = "\t";
		private static var tab2:String = "\t\t";
		private static var tab3:String = "\t\t\t";
		private static var tab4:String = "\t\t\t\t";
		
		private static var tmpBmps:Array;
		
		public static function exportScene (
									objectList:Vector.<SceneObject>, 
									lightList:Vector.<SceneLight>,
									cameraList:Vector.<Camera3d>,
									channels:Object=null
									 ) :void {
								
										 
			var objects:Object = {};
			var cameras:Object = {};
			var lights:Object = {};
			var materials:Object = {};
			var bmps:Object = {};
			
			var L:int = objectList.length;
			var i:int;
			if(objectList) {
				var so:SceneObject;
				var polyMat:Dictionary = new Dictionary(true);
				var matCount:int=0;
				var bmpCount:int=0;
				var sf:Surface;
				var atb:BitmapAttributes;
				var j:int;
				var L2:int;
				
				for(i=0; i<L; i++) {
					so = objectList[i];
					objects["obj"+i] = so;
					L2 = so.polygons.length;
					
					for( j=0; j < L2; j++ ) {
						sf = so.polygons[i].surface;
						if( polyMat [ sf ] == null ) {
							polyMat [ sf ] = true;
							materials["mat"+matCount] = sf;
							if(sf.attributes is BitmapAttributes) {
								atb = BitmapAttributes(sf.attributes);
								bmps["bitmap"+bmpCount] = { path:"", id: "bitmap"+bmpCount, clip: atb.texture};
								bmpCount++;
							}
							matCount++;
						}
					}
				}
			}
			if(lightList) {
				L = lightList.length;
				for(i=0; i<L; i++) {
					lights["light"+i] = lightList[i];
				}
			}
			if(cameraList) {
				L = cameraList.length;
				for(i=0; i<L; i++) {
					cameras["camera"+i] = cameraList[i];
				}
			}
			export(objects,lights,cameras,null,materials,bmps,channels);
		}
		
		public static function export ( objects:Object=null,
										lights:Object=null,
										cameras:Object=null, 
										sprites:Object=null,
										materials:Object=null,
										bmps:Object=null,
										channels:Object=null) :String 
		{
			tmpBmps = new Array();
			
			var rv:String='<we3d>' + nl;
			
			if(materials) 	rv += exp_material( materials, bmps );
			if(channels)	rv += exp_channel( channels );
			
			rv += nl + tab1 + '<scene>' + nl;
			if(cameras) 	rv += exp_camera( cameras );
			if(lights) 		rv += exp_light( lights);
			if(objects) 	rv += exp_object( objects, materials );
			if(sprites) 	rv += exp_sprite( sprites, bmps );
			rv += tab1 + '</scene>' + nl;
			
			if(tmpBmps.length > 0 ) 
			{
				rv += nl + tab1 + '<res>' + nl;
				
				for(var i:int=0; i<tmpBmps.length; i++) 
				{
					rv += nl + tab2 + '<clip id="' + tmpBmps[i].id + '" file="' + tmpBmps[i].path + '"></clip>' + nl;
				}
				rv += nl + tab1 + '</res>' + nl;
			}
			
			rv += '</we3d>' + nl;
			return rv;
		}
		
		public static function exp_shared (shared:Object) :String {
			var name:String;
			var rv:String = "";
			
			for( name in shared ) 
			{
				rv += name + ' = "' + shared[name] + '" ';
			}
			
			return rv;
		}
		
		public static function exp_channel ( channels:Object=null ) :String 
		{
			var rv:String= tab1 + "<channels>";
			
			if(channels) 
			{
				var cl:LinearChannel;
				var tp:String;
				var i:int;
				var L:int;
				var key:KeyFrame;
				for(var name:String in channels) 
				{
					cl = LinearChannel ( channels[name] );
					
					if(cl is EnvelopeChannel) tp = "envelope";
					else tp = "linear";
					
					rv += tab2 + '<c id="' +name+'" type="' +tp+ '" loop="'+(cl.loop?"1":"0")+'">'+nl;
					L = cl.keyFrames.length;
					
					for( i=0; i<L; i++) 
					{
						key = cl.keyFrames[i];
						
						rv += tab3 + '<key frame="'+key.frame+'" value="'+key.value+'" ease="'+WE3DLoader.easeFuncName(key.easeFunc)+'/>'+nl;
						
					}
					
					rv += tab2 + '<c/>'+nl;
				}
				
			}
			return rv + tab1 + "</channels>";
		}
		
		public static function exp_light (lights:Object=null) :String 
		{
			var rv:String="";
			var light:SceneLight;
			
			for(var name:String in lights) 
			{
				light = lights[name];
				rv += tab2 + '<light id="'+name+'" color="'+getCssColorString(light.color,true,"#")+'" intensity="'+light.intensity+'" ';

				if(light.radius > 0) rv += 'radius="'+light.radius+'" ';
				
				rv += exp_transform(light,false) + " ";
				
				if( light.shared != null) rv += exp_shared( light.shared );
					
				rv += '/>' + nl;
				
			}
			return rv;
		}
		
		public static function exp_sprite (sprites:Object=null, bmps:Object=null) :String 
		{
			var rv:String="";
			var sp:SceneSpriteF10;
			
			var bn:String;
			var bni:String;
			var bfound:Boolean=false;
			var imgid:int;
			var oi:Object;
			var clp:int;
			
			for(var name:String in sprites) 
			{
				sp = sprites[name];
				
				for(bni in bmps) 
				{
					oi = bmps[bni];
					
					if( oi.dobj == sp._clip ) 
					{
						bn = bni;
						imgid = oi.id;
						bfound=true;
						if(tmpBmps.indexOf(oi) == -1) tmpBmps.push(oi);
						break;
					}
				}
				
				if(bfound) {		
					clp = imgid;
					rv += tab2 + '<sprite id="'+name+ '"' + ' clip="' +clp + '"' + exp_transform(sp,false) + " ";
					if( sp.shared != null) rv += exp_shared( sp.shared );
					rv += '/>' + nl;
				}
				
			}
			
			return rv;
		}
				
		public static function exp_camera (cameras:Object=null) :String 
		{
			var rv:String="";
			var cam:Camera3d;
			
			for(var name:String in cameras) 
			{
				cam = cameras[name];
				rv += tab2 + '<cam id="'+name+'" width="'+cam.width+'" height="'+cam.height+'" fov="'+cam.fov+'"' + exp_transform(cam,false) + " ";
				if( cam.shared != null) rv += exp_shared( cam.shared );
				rv += '/>' + nl;
			}
			
			return rv;
		}
		
		public static function exp_particles (obj:SceneParticles) :String {
			var rv:String = '<emitter type="basic" ' +
			
			'generate="' + (obj.emitter.generatePerTick) + '" ' +
			'alpha="' + (obj.emitter.alpha) + '" ' +
			'centerx="' + (obj.emitter.center.x) + '" ' +
			'centery="' + (obj.emitter.center.y) + '" ' +
			'centerz="' + (obj.emitter.center.z) + '" ' +
			'color="' + (obj.emitter.color) + '" ' +
			'constrainrandomcolor="' + (obj.emitter.constrainRandomColor) + '" ' +
			'explosion="' + (obj.emitter.explosion) + '" ' +
			'gravityx="' + (obj.emitter.gravity.x) + '" ' +
			'gravityy="' + (obj.emitter.gravity.y) + '" ' +
			'gravityz="' + (obj.emitter.gravity.z) + '" ' +
			'lifetime="' + (obj.emitter.lifeTime) + '" ' +
			'nozzle="' + (obj.emitter.nozzle) + '" ' +
			'particlesize="' + (obj.emitter.particleSize) + '" ' +
			'randomalpha="' + (obj.emitter.randomAlpha) + '" ' +
			'randomblue="' + (obj.emitter.randomBlue) + '" ' +
			'randomcolor="' + (obj.emitter.randomColor) + '" ' +
			'randomexplosion="' + (obj.emitter.randomExplosion) + '" ' +
			'randomgreen="' + (obj.emitter.randomGreen) + '" ' +
			'randomlifetime="' + (obj.emitter.randomLifeTime) + '" ' +
			'randomparticlesize="' + (obj.emitter.randomParticleSize) + '" ' +
			'randomred="' + (obj.emitter.randomRed) + '" ' +
			'randomresistance="' + (obj.emitter.randomResistance) + '" ' +
			'randomweight="' + (obj.emitter.randomWeight) + '" ' +
			'resistance="' + (obj.emitter.resistance) + '" ' +
			'sizex="' + (obj.emitter.size.x) + '" ' +
			'sizey="' + (obj.emitter.size.y) + '" ' +
			'sizez="' + (obj.emitter.size.z) + '" ' +
			'velocityx="' + (obj.emitter.velocity_x) + '" ' +
			'velocityy="' + (obj.emitter.velocity_y) + '" ' +
			'velocityz="' + (obj.emitter.velocity_z) + '" ' +
			'weight="' + (obj.emitter.weight) + '" ' +
			'playing="'  + (obj.emitter.timer.running ? "1":"0") + '" />' +nl;
			/*
			if(emt.@alpha != undefined) pts.emitter.alpha = emt.@alpha;
			if(emt.@centerx != undefined) pts.emitter.center.x = emt.@centerx;
			if(emt.@centery != undefined) pts.emitter.center.y = emt.@centery;
			if(emt.@centerz != undefined) pts.emitter.center.z = emt.@centerz;
			if(emt.@color != undefined) pts.emitter.color = emt.@color;
			if(emt.@constrainrandomcolor != undefined) pts.emitter.constrainRandomColor = emt.@constrainrandomcolor == "1"?true:false;
			if(emt.@explosion != undefined) pts.emitter.explosion = emt.@explosion;
			if(emt.@gravityx != undefined) pts.emitter.gravity.x = emt.@gravityx;
			if(emt.@gravityy != undefined) pts.emitter.gravity.y = emt.@gravityy;
			if(emt.@gravityz != undefined) pts.emitter.gravity.z = emt.@gravityz;
			if(emt.@lifetime != undefined) pts.emitter.lifeTime = emt.@lifetime;
			if(emt.@nozzle != undefined) pts.emitter.nozzle = emt.@nozzle;
			if(emt.@particlesize != undefined) pts.emitter.particleSize = emt.@particlesize;
			if(emt.@randomalpha != undefined) pts.emitter.randomAlpha = emt.@randomalpha;
			if(emt.@randomblue != undefined) pts.emitter.randomBlue = emt.@randomblue;
			if(emt.@randomcolor != undefined) pts.emitter.randomColor = emt.@randomcolor;
			if(emt.@randomexplosion != undefined) pts.emitter.randomExplosion = emt.@randomexplosion;
			if(emt.@randomgreen != undefined) pts.emitter.randomGreen = emt.@randomgreen;
			if(emt.@randomlifetime != undefined) pts.emitter.randomLifeTime = emt.@randomlifetime;
			if(emt.@randomparticlesize != undefined) pts.emitter.randomParticleSize = emt.@randomparticlesize;
			if(emt.@randomred != undefined) pts.emitter.randomRed = emt.@randomred;
			if(emt.@randomresistance != undefined) pts.emitter.randomResistance = emt.@randomresistance;
			if(emt.@randomweight != undefined) pts.emitter.randomWeight = emt.@randomweight;
			if(emt.@resistance != undefined) pts.emitter.resistance = emt.@resistance;
			if(emt.@sizex != undefined) pts.emitter.size.x = emt.@sizex;
			if(emt.@sizey != undefined) pts.emitter.size.y = emt.@sizey;
			if(emt.@sizez != undefined) pts.emitter.size.z = emt.@sizez;
			if(emt.@velocityx != undefined) pts.emitter.velocity_x = emt.@velocityx;
			if(emt.@velocityy != undefined) pts.emitter.velocity_y = emt.@velocityy;
			if(emt.@velocityz != undefined) pts.emitter.velocity_z = emt.@velocityz;
			if(emt.@weight != undefined) pts.emitter.weight = emt.@weight;
			if(emt.@playing != undefined && emt.@playing=="1") pts.emitter.start();
			*/
			return  rv;
		}
 		
		public static function exp_object (objects:Object=null, surfaces:Object=null) :String 
		{
			var rv:String="";
			
			if(objects) {
				var obj:SceneObject;
				var objp:SceneParticles;
				var objm:SceneObjectMorph;
				var objb:SceneObjectBones;
				
				for(var name:String in objects) 
				{
					if(objects[name] is SceneParticles) 
					{
						objp = SceneParticles(objects[name]);
						
						rv += tab2 + '<particles id="'+name+'" type="'+(objp.renderer is ParticleDotRenderer?"dot":"sprite")+'"' + exp_transform(objp,true) + " ";
						if( objp.shared != null) rv += exp_shared( objp.shared );
						rv += '>' + nl;
						
						rv += tab2 + exp_particles(objp);
						
						rv += tab2 + exp_mesh(objp, surfaces);
						rv += tab2 + '</particles>' + nl;
						
					}else if(objects[name] is SceneObjectMorph) 
					{
						objm = SceneObjectMorph(objects[name]);
						
						rv += tab2 + '<morph id="'+name+'"' + exp_transform(objm,true) + " ";
						if( objm.shared != null) rv += exp_shared( objm.shared );
						rv += '>' + nl;
						
						rv += tab2 + exp_mesh_morph(objm, surfaces);
						rv += tab2 + '</morph>' + nl;
						
					}else if(objects[name] is SceneObjectBones) 
					{
						objb = SceneObjectBones(objects[name]);
						
						rv += tab2 + '<obj id="'+name+'"' + exp_transform(objb,true) + " ";
						if( objb.shared != null) rv += exp_shared( objb.shared );
						rv += '>' + nl;
						rv += tab2 + exp_mesh(objb, surfaces);
						rv += tab2 + '</obj>' + nl;
					}
					else
					{
						// SceneObject
						
						obj = SceneObject(objects[name]);
						
						rv += tab2 + '<obj id="'+name+'"' + exp_transform(obj,true) + " ";
						if( obj.shared != null) rv += exp_shared( obj.shared );
						rv += '>' + nl;
						rv += tab2 + exp_mesh(obj, surfaces);
						rv += tab2 + '</obj>' + nl;
					}
				}
			}
			return rv;
		}
		public static function getCssColorString ( col:uint, hex:Boolean=true, hexStr:String="0x" ) :String 
		{
			var r:int = col >> 16 & 255;
			var g:int = col >> 8 & 255;
			var b:int = col & 255;
			
			if( hex ) 
			{
				var rh:String = r.toString(16);
				var gh:String = g.toString(16);
				var bh:String = b.toString(16);
				
				return hexStr + (r<=16 ? "0" +rh:rh) + (g<=16 ? "0" +gh:gh) + (b<=16 ? "0" +bh:bh);
			}
			else
			{
				return "rgb(" + r +","+ g +","+ b+")";
			}
		}
		public static function exp_material (materials:Object=null,bmps:Object=null) :String 
		{
			var rv:String= tab1 + "<materials>";
			
			if(materials) {
				var mm:MaterialManager = new MaterialManager();
				var o:Object;
				var surf:Surface;
				var bn:String;
				var bni:String;
				var bfound:Boolean=false;
				var imgid:int;
				var oi:Object;
				
				for(var name:String in materials) 
				{
					surf = materials[name];	
					o = mm.getMaterialProperties( surf );
					
					rv += nl + tab2 + '<surface id="'+ name +'"'; // + mat properties
					
					for(var nam:String in o) 
					{
						if(nam != "name" && nam != "id") 
						{
							//if(nam != "lightGlobals") {
							//	rv += " " + nam + '="'+o[nam]+'"';
							//}
							
							bfound = false;
							
							switch (nam) 
							{
								// string
								case "id":
								case "name":
								
								// number
								case "alpha":
								case "lineAlpha":
								case "luminosity":
								case "diffuse":
								case "lineStyle":
								
								// boolean
								case "hideBackfaces":
								case "lighting":
								case "scanline":
								case "zbuffer":
								case "wireframe":
								case "curved":
								case "transparent":
								case "smooth":
								case "repeat":
									
									rv += " " + nam + '="'+o[nam]+'"';
									break;
								
								case "color":
								case "lineColor":
									rv += " " + nam + '="'+getCssColorString ( o[nam], true, "#" )+'"';
									break;
								
								case "bitmap":
																	
									for(bni in bmps) 
									{
										oi = bmps[bni];
										
										if( oi.clip == o[nam] ) 
										{
											bn = bni;
											imgid = oi.id;
											bfound=true;
											if(tmpBmps.indexOf(oi) == -1) tmpBmps.push(oi);
											break;
										}
									}
									if(bfound) {					
										rv += " " + nam + '="'+ imgid +'"';
									}
									break;
								
								case "lightGlobals":
									rv += " " + nam + '=""';						
									break;
							}
							
						}
					}
					
					if( surf.shared != null) rv += " " + exp_shared(surf.shared);
					
					rv += '/>';
				}
			}
			return rv + nl + tab1 + "</materials>";
		}
		
		private static function surfName (sf:Surface, surfs:Object) :String {
			for(var name:String in surfs) {
				if(surfs[name] === sf) {
					return name;
				}
			}
			return "";
		}
		
		public static function exp_mesh (obj:SceneObject, surfaces:Object) :String 
		{
			var rv:String="";
			
			if( obj.points.length == 0) return "";
			
			rv += tab2 + '<v>'+nl;
			
			var L:int = obj.points.length;
			var vt:Vertex;
			var i:int;
			
			for(i=0; i<L; i++) {
				/*vt = obj.points[i];
				rv += tab3 + '<v x="'+vt.x+'" y="'+vt.y+'" z="'+vt.z+'"/>' + nl;*/
				vt = obj.points[i];
				rv += tab3 + '<v x="'+vt.x+'" y="'+vt.y+'" z="'+vt.z+'"';
				if( vt.normal != null ){
					rv += ' nx="'+vt.normal.x+'" ny="'+vt.normal.y+'" nz="'+vt.normal.z+'"'
				}
				if(vt.color >= 0) {
					rv += ' col="'+vt.color+'" alpha="'+vt.alpha+'"';
				}
				
				rv += '/>' + nl;
			}
			rv += tab2 + '</v>' + nl;
			
			L = obj.polygons.length;
			
			if( L > 0) 
			{
				uvidIndex = {};
				uvidCount = 0;
				uvidList = [];
				
				var f:Face;
				var t1:String= tab2 + "<f>";
				var t2:String= tab2 + "<t>";
				var prevmat:Surface;
				var j:int;
				var k:int;
				
				for(i=0; i<L; i++) 
				{
					f = obj.polygons[i];
					t1 += tab3 + '<f ';
					if(f.surface != prevmat) {
						t1 += 'mat="'+ surfName( f.surface, surfaces ) +'" ';
						prevmat = f.surface;
					}
					
					// find point ids
					k = f.vLen;
					t1 += 'vts="';
					for(j=0; j<k-1; j++) {
						t1 += '' + obj.getPointId( f.vtxs[j] ) + ',';
					}
					t1 += '' + obj.getPointId( f.vtxs[j] ) + '" ';// />'+nl;
					
					// find uv ids
					if(f.uvs != null) {
						k = f.uvs.length;
						t1 += 'uvs="';
						for(j=0; j<k-1; j++) {
							t1 += '' + getUVId( f.uvs[j] ) + ',';
						}
						t1 += '' + getUVId( f.uvs[j] );// + '" />'+nl;
					}
					
					t1 += '" />'+nl;
				}
				
				if(uvidList.length > 0) 
				{
					k = uvidList.length;
					
					t2 += nl;
					for(i=0; i<k; i++) 
					{
						t2 += tab3 + '<t u="' + uvidList[i].u + '" v="'+ uvidList[i].v + '"/>' + nl;
					}
				}
				
				t1 += tab2 + '</f>' + nl;
				t2 += '</t>' + nl;
				
				rv += t2 + t1;
			}
			return rv;
		}
		
		public static function exp_mesh_morph (obj:SceneObjectMorph, surfaces:Object) :String 
		{
			var rv:String="";
			
			if( obj.points.length == 0 ) return "";
			
			
			
			var L:int;//= obj.points.length;
			var vt:Vertex;
			var i:int;
			var frames:int = obj.morphFrames.length;
			var pts:Vector.<Vertex>;
			
			for( var fr:int=0; fr<frames; fr++ ) 
			{
				pts = obj.morphFrames[fr].points;
				L = pts.length;
				rv += tab2 + '<v id="'+obj.morphFrames[fr].name+'">'+nl;
				for(i=0; i<L; i++) {
					vt = pts[i];
					rv += tab3 + '<v x="'+vt.x+'" y="'+vt.y+'" z="'+vt.z+'"';
					if( vt.normal != null ){
						rv += ' nx="'+vt.normal.x+'" ny="'+vt.normal.y+'" nz="'+vt.normal.z+'"'
					}
					if(vt.color >= 0) {
						rv += ' col="'+vt.color+'" alpha="'+vt.alpha+'"';
					}
					rv += '/>' + nl;
				}
				rv += tab2 + '</v>' + nl;
			}
			
			var playlist:Array = obj.getPlayList(false);
			L = playlist.length;
			if(L>0) 
			{
				rv += tab2 + "<playlist>"+nl;
				for(i=0; i<L; i++) {
					
					rv += tab3 + '<frame id="'+playlist[i].id+'" duration="'+playlist[i].duration+'"/>' + nl;
				}
				rv += tab2 + "</playlist>" + nl;
			}
			
			L = obj.polygons.length;
			
			if( L > 0) 
			{
				uvidIndex = {};
				uvidCount = 0;
				uvidList = [];
				
				var f:Face;
				var t1:String= tab2 + "<f>";
				var t2:String= tab2 + "<t>";
				var prevmat:Surface;
				var j:int;
				var k:int;
				
				for(i=0; i<L; i++) 
				{
					f = obj.polygons[i];
					t1 += tab3 + '<f ';
					if(f.surface != prevmat) {
						t1 += 'mat="'+ surfName( f.surface, surfaces ) +'" ';
						prevmat = f.surface;
					}
					
					// find point ids
					k = f.vLen;
					t1 += 'vts="';
					for(j=0; j<k-1; j++) {
						t1 += '' + obj.getPointId( f.vtxs[j] ) + ',';
					}
					t1 += '' + obj.getPointId( f.vtxs[j] ) + '" ';// />'+nl;
					
					// find uv ids
					if(f.uvs != null) {
						k = f.uvs.length;
						t1 += 'uvs="';
						for(j=0; j<k-1; j++) {
							t1 += '' + getUVId( f.uvs[j] ) + ',';
						}
						t1 += '' + getUVId( f.uvs[j] );// + '" />'+nl;
					}
					
					t1 += '" />'+nl;
				}
				
				if(uvidList.length > 0) 
				{
					k = uvidList.length;
					
					t2 += nl;
					for(i=0; i<k; i++) 
					{
						t2 += tab3 + '<t u="' + uvidList[i].u + '" v="'+ uvidList[i].v + '"/>' + nl;
					}
				}
				
				t1 += tab2 + '</f>' + nl;
				t2 += '</t>' + nl;
				
				rv += t2 + t1;
			}
			return rv;
		}
		
		private static var uvidList:Array;
		private static var uvidIndex:Object;
		private static var uvidCount:int;
		
		private static function getUVId (uv:UVCoord):uint 
		{
			var obj:Object = uvidIndex[ "_" + uv.u + "_" + uv.v];
			var rv:int;
			
			if( obj != null) {
				rv = uint(obj);
			}else{
				uvidIndex[ "_"+uv.u+"_"+uv.v] = uvidCount;
				rv = uvidCount;
				uvidList.push( uv );
				uvidCount++;
			}
			return rv;
		}
		
		public static function exp_transform (obj:Object3d, allowScale:Boolean=false) :String 
		{
			var rv:String="";
			if(obj != null) {
				if(obj.transform.x != 0) rv += ' x="'+ obj.transform.x +'"';
				if(obj.transform.y != 0) rv += ' y="'+ obj.transform.y +'"';
				if(obj.transform.z != 0) rv += ' z="'+ obj.transform.z +'"';
				
				if(obj.transform.rotationX != 0) rv += ' rx="'+ obj.transform.rotationX +'"';
				if(obj.transform.rotationY != 0) rv += ' ry="'+ obj.transform.rotationY +'"';
				if(obj.transform.rotationZ != 0) rv += ' rz="'+ obj.transform.rotationZ +'"';
				
				if(allowScale) {
					if(obj.transform.scaleX != 1) rv += ' sx="'+ obj.transform.scaleX +'"';
					if(obj.transform.scaleY != 1) rv += ' sy="'+ obj.transform.scaleY +'"';
					if(obj.transform.scaleZ != 1) rv += ' sz="'+ obj.transform.scaleZ +'"';
				}
			}
				
			return rv;
		}
	}
}