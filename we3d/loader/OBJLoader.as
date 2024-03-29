package we3d.loader 
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import we3d.we3d;
	import we3d.loader.SceneLoader;
	import we3d.loader.TF;
	import we3d.material.Surface;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.scene.SceneObject;
	import we3d.ui.Console;

	use namespace we3d;
	
	
	/**
	* Load WaveFront OBJ Files. <br/>
	* <br/>
	* The <code>loadedSurfaces</code> can be assigned before the file is loaded <br/>
	* <br/>
	* Support:<br/>
	* <br/>
	* - Parse Groups into SceneObjects <br/>
	* - Parse Lines, Triangles, Quads and Polygons <br/>
	* - UV Mapping <br/>
	* - Vertex Normals <br/> 
	*/
	public class OBJLoader extends SceneLoader 
	{
		public function OBJLoader () {}
		
		/** 
		* Object with surfaces for the polygons in the 3D file. <br/> 
		* The surfaces should be assigned before the file is loaded. <br/>
		* 
		* <code><pre>
		* 	import we3d.loader.OBJLoader;
		* 	ldr = new OBJLoader();
		* 	ldr.loadedSurfaces["Default"] = new Surface();
		* 	ldr.loadedSurfaces["Wall"] = new Surface();
		* 	ldr.loadFile("myobjfile.obj");
		* </pre></code>
		*/
		public var loadedSurfaces:Object = {};
		
		private var piid:int=-1;
		private var uvs:Array;
		private var vtxNormals:Array;
		private var vns:Array;
		private var allpoints:Array;
		private var tf:TF;
		private var currentLine:int;
		
		public override function parseFile (bytes:ByteArray) :void 
		{
			tf = new TF()
			tf.setFile(bytes.toString());
			
			super.init();
			
			status = 0;
			fileObjects.push(new SceneObject());
			objectsByName[filename] = fileObjects[fileObjects.length-1];
			currObject = fileObjects[0];
			
			
			loadedSurfaces[filename] = new Surface();
			fileSurfaces.push( loadedSurfaces[filename] );
			surfacesByName[filename] = fileSurfaces[fileSurfaces.length-1];	
			currSurface = loadedSurfaces[filename];
			
			vtxNormals = [];
			uvs = [];
			allpoints = [];
			currentLine = 0;
			
			if(blocking) {
				var L:int = tf._file.length;
				for(var i:int=0; i<L; i++) parseNextLine(tf._file[i]);
				finishParse();
			}else{
				if(piid != -1) clearInterval(piid);
				piid = setInterval(parseStep, loadParseInterval);
			}
		}
		
		private function parseStep () :void
		{
			var L:int = tf._file.length;
			status = int((currentLine/L) * 100);
			for(var i:int=0; i<linesPerFrame; i++) {
				if(currentLine < L) {
					parseNextLine(clearWhite(tf._file[currentLine]));
					currentLine++;
				}else{
					finishParse();
					break;
				}
			}
		}
		
		private function parseNextLine (lin:String) :void {
			var c1:String = lin.charAt(0);
			
			if( c1 == "#" || lin.length < 3) {
				return;
			}
			
			var c2:String = lin.charAt(1).toLowerCase();
			var str:String;
			var id:int;
			var fc:Face;
			var j:int;
			var i:int;
			var ouv:Array;
			var p:Array;
			var pts:Array;
			var tmp:Array;
			var vn:Array;
			var n:String;
			var n2:String;
			var str1:String;
			var uvid:Number;
			var u:Number;
			var v:Number;
			
			if(c2 == " " || c2=="o") {
				if(c1 == "g") {
					if(fileObjects.length == 1 && currObject.points.length == 0) {
						return;
					}else{
						fileObjects.push(new SceneObject());
						var name:String = lin.substring(3, lin.length);
						objectsByName[name] = fileObjects[fileObjects.length-1];
						currObject = fileObjects[fileObjects.length-1];
					}
				}
				else if(c1 == "v") 
				{
					n2 = lin.substring(2, lin.length);
					p = n2.split(" ");
					allpoints.push( new Vertex(Number(p[0])*scaleX, Number(p[1])*scaleY, Number(p[2])*scaleZ) );
				}
				else if(c1 == "f" || c1 == "l") 
				{
					var st:int=lin.indexOf(" ");
					
					n2 = lin.substring(st+1, lin.length);
					p = n2.split(" ");
					
					if(p.length > 0) 
					{
						ouv = [];
						pts = [];
						vn = [];
						
						for(i=0; i<p.length; i++) 
						{
							str1 = p[i];
							
							if(str=="") continue;
							
							if(str1.indexOf("/") >= 0) 
							{
								tmp = str1.split("/");
								
								uvid = Number(tmp[0]);
								if(uvid < 0) {
									pts[i] = allpoints.length + uvid;
								}else{
									pts[i] = uvid-1;
								}
								
								uvid = Number(tmp[1]);
								if(uvid < 0) {
									ouv[i] = uvs[uvs.length + uvid];
								}else{
									ouv[i] = uvs[uvid-1];
								}
								if(tmp.length>2) {
									uvid = Number(tmp[2]);
									if(uvid < 0) {
										vn[i] = vtxNormals[vtxNormals.length + uvid];
									}else{
										vn[i] = vtxNormals[uvid-1];
									}
								}
							}
							else
							{
								uvid = Number(str1);
								if(uvid < 0) {
									pts[i] = allpoints.length + uvid;
								}else{
									pts[i] = uvid-1;
								}
							}
						}
						
						if(pts.length > 1) 
						{
							var nvts:Array = [];
							var pt:Vertex;
							var ptid:int;
							
							for(i=0; i<pts.length; i++) 
							{
								pt = Vertex(allpoints[ pts[i] ]);
								if(pt) {
									ptid = nvts.push( currObject.addVertex(pt) );
									if(vn.length > i) 
									{
										currObject.points[ptid].normal = vtxNormals[vn[i]];
									}
								}
							}
							
							if(flipped) 
							{
								fc = currObject.addPolygon(currSurface, nvts.reverse());
								if(ouv.length > 1) {
									for(i=ouv.length-1; i >= 0; i--) {
										fc.addUvCoord(ouv[i].u, ouv[i].v);
									}
								}
							}
							else
							{
								fc = currObject.addPolygon(currSurface, nvts);
								if(ouv.length > 1) {
									for(i=0; i<ouv.length; i++) {
										fc.addUvCoord(ouv[i].u, ouv[i].v);
									}
								}
							}
							
						}
					}
				}
			}
			else if(c1 == "u" && c2 == "s") 
			{
				if(lin.substring(0,6) == "usemtl") {
					n = lin.substring(7, lin.length);
					if(loadedSurfaces[n] == null) {
						loadedSurfaces[n] = new Surface();
						fileSurfaces.push( loadedSurfaces[n] );
						surfacesByName[n] = fileSurfaces[fileSurfaces.length-1];
					}
					currSurface = loadedSurfaces[n];
				}
			}
			else if(c1+c2 == "vt") 
			{
				str = lin.substring(3, lin.length);
				p = str.split(" ");
				u = Number(p[0]);
				v = Number(p[1]);
				uvs.push( new UVCoord(u<0?-u:u, 1-(v<0?-v:v)) );
			}
			else if(c1+c2 == "vn") 
			{
				str = lin.substring(3, lin.length);
				p = str.split(" ");
				vtxNormals.push( new Vector3d( Number(p[0]), Number(p[1]), Number(p[1]) ) );
			}
		}
		
		private function clearWhite (e:String) :String {
			var str:String = e.charAt(e.length-1);
			for(var i:Number=e.length-2; i>=0; i--) {
				if(e.charCodeAt(i) > 32 || e.charCodeAt(i+1) > 32) {
					str = e.charAt(i) + str;
				}
			}
			return str;
		}
		
		private function finishParse () :void 
		{			
			clearInterval(piid);
			piid = -1;
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			vtxNormals = null;
			uvs = null;
			allpoints = null;
			loadedSurfaces = null;
			tf.clear();
			clearMemory();
		}
		
	}
}