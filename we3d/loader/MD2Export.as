package we3d.loader
{	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import we3d.we3d;
	import we3d.core.culling.BoxCulling;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.scene.MorphFrame;
	import we3d.scene.SceneObjectMorph;
	use namespace we3d;
	
	public class MD2Export {

		public static function export (object:SceneObjectMorph, texture:String="map.png", textureWidth:int=512, textureHeight:int=512, frames:*=null) :ByteArray 
		{
			
			var uvs:Vector.<int> = new Vector.<int>(); 			// /2
			var tris:Vector.<uint> = new Vector.<uint>();    	// /6 3 int vert ids, 3 int uv ids
			var ptCount:int=0;
			var uvCount:int=0;
			var triCount:int=0;
			
			if(frames == null)
				frames = object.morphFrames;
			else 
				frames = Vector.<MorphFrame>(frames);
			
			var L:int = object.polygons.length
			var fc:Face;
			var vtxs:Vector.<Vertex>;
			var pt:Vertex;
			var uv:UVCoord;
			var L2:int;
			var uvTable:Dictionary = new Dictionary(true);
			var j:int;
			var fTriA:int=0;
			var fTriB:int=0;
			var fTriC:int=0;
			
			var fuvA:int=0;
			var fuvB:int=0;
			var fuvC:int=0;
			var tu:int;
			var tv:int;
			
			var points:int=object.points.length;
			var uvCoords:int=0;
			var i:int;
			
			for(i = 0; i<L; i++)
			{
				fc = object.polygons[i];
				vtxs = fc.vtxs;
				L2 = vtxs.length;
				
				if(L2 >= 3) 
				{
					fTriA = object.getPointId( fc.a );
					fTriB = object.getPointId( fc.b );
					fTriC = object.getPointId( fc.c );
					
					tris[ triCount ] = fTriC;  triCount++;
					tris[ triCount ] = fTriB;  triCount++;
					tris[ triCount ] = fTriA;  triCount++;
					
					if( fc.uvs.length >= 3 ) 
					{
						uv = fc.uvs[0];
						tu = int( uv.u * textureWidth );
						tv = int( uv.v * textureHeight );
						if( uvTable[ tu + "_" + tv ] != null ) {
							fuvA = uvTable[ tu + "_" + tv ];
						}else{
							uvs [ uvCount ] = tu; uvCount++;
							uvs [ uvCount ] = tv; uvCount++;
							uvTable[ tu + "_" + tv ] = uvCoords;
							fuvA = uvCoords;
							uvCoords++;
						}
						
						uv = fc.uvs[1];
						tu = int( uv.u * textureWidth );
						tv = int( uv.v * textureHeight );
						if( uvTable[ tu + "_" + tv ] != null ) {
							fuvB = uvTable[ tu + "_" + tv ];
						}else{
							uvs [ uvCount ] = tu; uvCount++;
							uvs [ uvCount ] = tv; uvCount++;
							uvTable[ tu + "_" + tv ] = uvCoords;
							fuvB = uvCoords;
							uvCoords++;
						}
						uv = fc.uvs[2];
						tu = int( uv.u * textureWidth );
						tv = int( uv.v * textureHeight );
						if( uvTable[ tu + "_" + tv ] != null ) {
							fuvC = uvTable[ tu + "_" + tv ];
						}else{
							uvs [ uvCount ] = tu; uvCount++;
							uvs [ uvCount ] = tv; uvCount++;
							uvTable[ tu + "_" + tv ] = uvCoords;
							fuvC = uvCoords;
							uvCoords++;
						}
						
						tris[ triCount ] = fuvC;  triCount++;
						tris[ triCount ] = fuvB;  triCount++;
						tris[ triCount ] = fuvA;  triCount++;
					}
					else 
					{
						if( uvTable["0_0"] != null ) {
							fuvA = uvTable["0_0"];
						}else{
							uvs [ uvCount ] = 0; uvCount++;
							uvs [ uvCount ] = 0; uvCount++;
							uvTable["0_0"] = uvCoords;
							fuvA = uvCoords;
							uvCoords++;
						}
						tris[ triCount ] = fuvA;  triCount++;
						tris[ triCount ] = fuvA;  triCount++;
						tris[ triCount ] = fuvA;  triCount++;
						
					}
				}
			}
			
			var ofs_start:int;
			var ofs_skins:int;
			var ofs_st:int;
			var ofs_tris:int;
			var ofs_frames:int;
			var ofs_glcmd:int;
			var ofs_end:int;
			var frame_name:String;
			var vertices:Vector.<Vertex>;
			var vL:int = 0;
			var triangles:int = tris.length / 6;
			
			var rv:ByteArray = new ByteArray();
			rv.endian = Endian.LITTLE_ENDIAN;
			
			rv.writeInt( 844121161 );		// IDP2
			rv.writeInt ( 8 );				// VERSION
			rv.writeInt ( textureWidth );	// SKIN WIDTH
			rv.writeInt ( textureHeight ); 	// SKIN HEIGHT
			rv.writeInt ( 40 + 4 * points );  // FRAMESIZE
			rv.writeInt ( 0 );  			// NUM SKINS
			rv.writeInt ( points );		 	// NUM VERTICES
			rv.writeInt ( uvCoords ); 		// NUM TEXTURE COORDS
			rv.writeInt ( triangles ); 		// NUM TRIS
			rv.writeInt ( 0 );				// NUM GLCMDS
			rv.writeInt ( frames.length );// NUM FRAMES
			
			ofs_start = rv.position;
			rv.writeInt ( 0 );				// OFFSET SKINS
			rv.writeInt ( 0 );				// OFFSET TEXTURE COORDS
			rv.writeInt ( 0 );				// OFFSET TRIS
			rv.writeInt ( 0 );				// OFFSET FRAME DATA
			rv.writeInt ( 0 );				// OFFSET GLCMDS
			rv.writeInt ( 0 );				// OFFSET END
			
			ofs_skins = rv.position;
			ofs_st = rv.position;
			
			for( i=0; i < uvCount; i++){
				rv.writeShort( uvs[i] );
			}
			
			ofs_tris = rv.position;
			
			for(i=0; i < triCount; i++) {
				rv.writeShort( tris[i] );
			}
			
			ofs_frames = rv.position;
			
			var trX:Number;
			var trY:Number;
			var trZ:Number;
			
			var sizeX:Number;
			var sizeY:Number;
			var sizeZ:Number;
			var culler:BoxCulling;
			
			L = frames.length;
			for(i=0; i<L; i++) 
			{
				vertices = frames[i].points;
				vL = vertices.length;
				
				if(vL > 0 && vL == points) {
					
					frame_name = frames[i].name;
					
					culler = BoxCulling(frames[i].objectCuller);
					sizeX = (culler.maxx - culler.minx)/255;
					sizeY = (culler.maxy - culler.miny)/255;
					sizeZ = (culler.maxz - culler.minz)/255;
					
					rv.writeFloat( sizeX );
					rv.writeFloat( sizeZ );
					rv.writeFloat( sizeY );
					
					sizeX = 1/sizeX;
					sizeY = 1/sizeY;
					sizeZ = 1/sizeZ;
					
					trX = culler.minx;
					trY = culler.miny;
					trZ = culler.minz;
										
					rv.writeFloat( trX );
					rv.writeFloat( trZ );
					rv.writeFloat( trY );
					
					for (j = 0; j < 16; j++) {
						if( j >= frame_name.length ) {
							rv.writeByte(0);
						}else{
							rv.writeByte(frame_name.charCodeAt(j));
						}
					}
					
					for(j=0; j<vL; j++) {
						pt = vertices[j];
						rv.writeByte( int((pt.x-trX)*sizeX) );
						rv.writeByte( int((pt.z-trZ)*sizeZ) );
						rv.writeByte( int((pt.y-trY)*sizeY) );
						rv.writeByte( (pt.normal==null ? 0 : MD2Normals.findNormal(pt.normal)) );
					} 
				}
				
				
			}
				
			ofs_end = rv.position;
			
			rv.position = ofs_start;
			rv.writeInt ( ofs_st );				// OFFSET SKINS
			rv.writeInt ( ofs_st );				// OFFSET TEXTURE COORDS
			rv.writeInt ( ofs_tris );			// OFFSET TRIS
			rv.writeInt ( ofs_frames );			// OFFSET FRAME DATA
			rv.writeInt ( ofs_end );			// OFFSET GLCMDS
			rv.writeInt ( ofs_end );			// OFFSET END
			
			return rv;
		}
		
	}
	
	
}