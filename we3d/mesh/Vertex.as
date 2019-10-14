﻿package we3d.mesh {	import we3d.math.Vector3d;		/**	 * Vertex is a point in a mesh object (SceneObject). You create vertexes with the sceneObject.addPoint method	 */ 	public class Vertex 	{		public function Vertex (ax:Number=0, ay:Number=0, az:Number=0) {			x = ax;			y = ay;			z = az;		}				public var x:Number;		public var y:Number;		public var z:Number;		public var sx:Number=0;		public var sy:Number=0;		public var wz:Number=0;		public var wx:Number=0;		public var wy:Number=0;		public var color:int=-1;		public var alpha:Number=1;		public var normal:Vector3d;		public var culled:Boolean=false;		public var frameCounter1:int=-9876505;		public var frameCounter2:int=-9876505;				public function toString() :String {			return "( "+x.toFixed(2) + ", " + y.toFixed(2) + ", " + z.toFixed(2) + " )";		}		public function assign (vx:Number, vy:Number, vz:Number) :void {			x = vx;			y = vy;			z = vz;		}				public function clone () :Vertex {			var rv:Vertex = new Vertex(x,y,z);			rv.sx = sx;			rv.sy = sy;			rv.wx = wx;			rv.wy = wy;			rv.wz = wz;			rv.color = color;			rv.frameCounter1 = frameCounter1;			rv.frameCounter2 = frameCounter2;			if(normal != null) {				rv.normal = normal.clone();			}			return rv;		}	}	}