﻿package we3d.modeler.view{	import we3d.we3d;	import we3d.math.Matrix3d;	import we3d.mesh.Face;	import we3d.mesh.Vertex;	import we3d.scene.SceneObject;

	use namespace we3d;		/**	 * Allows to select points and polygons by bounding box values	 */ 	public class SelectTool 	{				public function SelectTool () {}				/**		* Selects all polygons in a SceneObject wich are in the bounding box low - high.		 * 		 * @param	obj		 * @param	low bounding box		 * @param	high bounding box		 * @param	allInside  If true a polygon is selected if all points are in the bounding box, otherwise if only one point is in the box.		 * @return		 */		public static function selPolyInBox (obj:SceneObject, low:Object, high:Object, allInside:Boolean=false) :Array {						var lx:Number;	var hx:Number;			var ly:Number;	var hy:Number;			var lz:Number;	var hz:Number;						if( low.x > high.x) {				lx = high.x;				hx = low.x;			}else{				lx = low.x;				hx = high.x;			}						if(low.y > high.y) {				ly = high.y;				hy = low.y;			}else{				ly = low.y;				hy = high.y;			}						if(low.z > high.z) {				lz = high.z;				hz = low.z;			}else{				lz = low.z;				hz = high.z;			}									var rv:Array = new Array();			var L:int = obj.polygons.length;			var i:int;			var j:int;			var pL:int;			var f:Face;			var vt:Vertex;						if(!allInside) {								for(i=0; i<L; i++) {					f = obj.polygons[i];										pL = f.vLen;										for(j=0; j<pL; j++) {						vt = f.vtxs[j];												if(vt.x >= lx && vt.x <= hx &&						   vt.y >= ly && vt.y <= hy &&						   vt.z >= lz && vt.z <= hz ) 						{							rv.push(f);							break;						}					}				}							}else{								var e:Boolean;				for(i=0; i<L; i++) {					f = obj.polygons[i];										pL = f.vLen;					e = true;										for(j=0; j<pL; j++) {						vt = f.vtxs[j];												if(vt.x <= lx || vt.x >= hx ||						   vt.y <= ly || vt.y >= hy ||						   vt.z <= lz || vt.z >= hz ) 						{							e = false;							break;						}					}										if(e) rv.push(f);				}			}						return rv;		}				public static const LOCAL:int=0;		public static const WORLD:int=1;		public static const CAMERA:int=2;				/**		* Returns an Array of points wich are in the bounding box		* @param	obj		* @param	low bounding box		* @param	high bounding box		* @return array with integer id's from the points list		*/		public static function selPointInBox (obj:SceneObject, low:Object, high:Object, cs:int=LOCAL) :Array {						var lx:Number;	var hx:Number;			var ly:Number;	var hy:Number;			var lz:Number;	var hz:Number;						if( low.x > high.x) {				lx = high.x;				hx = low.x;			}else{				lx = low.x;				hx = high.x;			}						if(low.y > high.y) {				ly = high.y;				hy = low.y;			}else{				ly = low.y;				hy = high.y;			}						if(low.z > high.z) {				lz = high.z;				hz = low.z;			}else{				lz = low.z;				hz = high.z;			}									var rv:Array = new Array();			var L:int = obj.points.length;			var i:int;			var j:int;			var vt:Vertex;						switch(cs) {				case LOCAL:					for(i=0; i<L; i++) 					{						vt = obj.points[i];						if(vt.x >= lx && vt.x <= hx && vt.y >= ly && vt.y <= hy && vt.z >= lz && vt.z <= hz ) rv.push(i);					}					break;				case WORLD:					var x:Number;	var y:Number;	var z:Number;					var m:Matrix3d = obj.transform.gv;					for(i=0; i<L; i++) {						vt = obj.points[i];						x = m.a*vt.x + m.e*vt.y + m.i*vt.z + m.m;						y = m.b*vt.x + m.f*vt.y + m.j*vt.z + m.n;						z = m.c*vt.x + m.g*vt.y + m.k*vt.z + m.o;						if(x >= lx && x <= hx && y >= ly && y <= hy && z >= lz && z <= hz ) rv.push(i);					}					break;				case CAMERA:					for(i=0; i<L; i++) 					{						vt = obj.points[i];						if(vt.wx >= lx && vt.wx <= hx && vt.wy >= ly && vt.wy <= hy && vt.wz >= lz && vt.wz <= hz ) rv.push(i);					}					break;			}			return rv;		}			}}