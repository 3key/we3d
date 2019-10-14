package we3d.mesh
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.material.ISurfaceAttributes;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneLight;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	*	Mesh data for GPU rendering 
	*/ 
	public class MeshBuffer
	{
		public function MeshBuffer () :void {
			currBuffer = this;
		}
		
		public var prg:MeshProgram;
		public var so:SceneObject;
		
		public var buffer:Vector.<Number> = new Vector.<Number>();
		public var vertexBuffer:Object;
		public var ib:Vector.<uint> = new Vector.<uint>();
		public var indexBuffer:Object;
		
		internal var id:uint=0;
		
		private var subBuffer:Vector.<MeshBuffer>;
		private static var vec4:Vector.<Number>= Vector.<Number>([0,0,0,1]);
		private static var vec8:Vector.<Number>= Vector.<Number>([0,0,0,1, 0,0,0,0]);
		
		private var currBuffer:MeshBuffer;
		private static var maxBuffer:int=25000;
		
		public function addFace (f:Face, va:Vertex, vb:Vertex, vc:Vertex) :void 
		{
			if(currBuffer.id > maxBuffer) {
				var smb:MeshBuffer = new MeshBuffer();
				smb.prg = prg;
				if(subBuffer == null) subBuffer = new Vector.<MeshBuffer>();
				subBuffer.push( smb );
				currBuffer = smb;
			}
			var bfr : Vector.<Number> = currBuffer.buffer;
			
			var count:int = bfr.length;
			
			if(prg.tx) 
			{
				if( prg.lighting ) 
				{
					if(va.normal != null) {
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						bfr[ count ] = f.u1;	count++;
						bfr[ count ] = f.v1;	count++;
						bfr[ count ] = va.normal.x;	count++;
						bfr[ count ] = va.normal.y;	count++;
						bfr[ count ] = va.normal.z;	count++;
					}else{
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						bfr[ count ] = f.u1;	count++;
						bfr[ count ] = f.v1;	count++;
						bfr[ count ] = f.normal.x;	count++;
						bfr[ count ] = f.normal.y;	count++;
						bfr[ count ] = f.normal.z;	count++;
					}
					
					if(vb.normal != null) {
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						bfr[ count ] = f.u2;	count++;
						bfr[ count ] = f.v2;	count++;
						bfr[ count ] = vb.normal.x;	count++;
						bfr[ count ] = vb.normal.y;	count++;
						bfr[ count ] = vb.normal.z;	count++;
					}else{
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						bfr[ count ] = f.u2;	count++;
						bfr[ count ] = f.v2;	count++;
						bfr[ count ] = f.normal.x;	count++;
						bfr[ count ] = f.normal.y;	count++;
						bfr[ count ] = f.normal.z;	count++;
					} 
					
					if(vc.normal != null) {
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						bfr[ count ] = f.u3;	count++;
						bfr[ count ] = f.v3;	count++;
						bfr[ count ] = vc.normal.x;	count++;
						bfr[ count ] = vc.normal.y;	count++;
						bfr[ count ] = vc.normal.z;	count++;
					}else{
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						bfr[ count ] = f.u3;	count++;
						bfr[ count ] = f.v3;	count++;
						bfr[ count ] = f.normal.x;	count++;
						bfr[ count ] = f.normal.y;	count++;
						bfr[ count ] = f.normal.z;	count++;
					}
				}
				else
				{
					bfr[ count ] = va.x;	count++;
					bfr[ count ] = va.y;	count++;
					bfr[ count ] = va.z;	count++;
					bfr[ count ] = f.u1;	count++;
					bfr[ count ] = f.v1;	count++;
					
					bfr[ count ] = vb.x;	count++;
					bfr[ count ] = vb.y;	count++;
					bfr[ count ] = vb.z;	count++;
					bfr[ count ] = f.u2;	count++;
					bfr[ count ] = f.v2;	count++;
					
					bfr[ count ] = vc.x;	count++;
					bfr[ count ] = vc.y;	count++;
					bfr[ count ] = vc.z;	count++;
					bfr[ count ] = f.u3;	count++;
					bfr[ count ] = f.v3;	count++;
				}
			}
			else
			{
				var r:Number;
				var g:Number;
				var b:Number;
				var a:Number;
				var _color:int;
				
				if( prg.a < 1 ) 
				{
					if( prg.lighting ) {
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						
						if(va.color >= 0) 
						{
							_color = va.color;	
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = va.alpha; count++;   // a
							
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
						if(va.normal != null) {
							bfr[ count ] = va.normal.x;	count++;
							bfr[ count ] = va.normal.y;	count++;
							bfr[ count ] = va.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						
						if(vb.color >= 0) {
							_color = vb.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = vb.alpha; count++;   // a
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
						if(vb.normal != null) {
							bfr[ count ] = vb.normal.x;	count++;
							bfr[ count ] = vb.normal.y;	count++;
							bfr[ count ] = vb.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						
						if(vc.color >= 0) {
							_color = vc.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = vc.alpha; count++;   // a
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
						if(vc.normal != null) {
							bfr[ count ] = vc.normal.x;	count++;
							bfr[ count ] = vc.normal.y;	count++;
							bfr[ count ] = vc.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
					}
					else
					{
						
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						
						if(va.color >= 0) {
							_color = va.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = va.alpha; count++;   // a
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						
						if(vb.color >= 0) {
							_color = vb.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = vb.alpha; count++;   // a
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						
						if(vc.color >= 0) {
							_color = vc.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
							bfr [ count ] = vc.alpha; count++;   // a
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
							bfr [ count ] = prg.a;  count++;
						}
						
					}
				}
				else
				{
					// NO ALPHA
					
					if( prg.lighting ) {
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						
						if(va.color >= 0) 
						{
							_color = va.color;	
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						}
						
						if(va.normal != null) {
							bfr[ count ] = va.normal.x;	count++;
							bfr[ count ] = va.normal.y;	count++;
							bfr[ count ] = va.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						
						if(vb.color >= 0) {
							_color = vb.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						}
						
						if(vb.normal != null) {
							bfr[ count ] = vb.normal.x;	count++;
							bfr[ count ] = vb.normal.y;	count++;
							bfr[ count ] = vb.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						
						if(vc.color >= 0) {
							_color = vc.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						}
						
						if(vc.normal != null) {
							bfr[ count ] = vc.normal.x;	count++;
							bfr[ count ] = vc.normal.y;	count++;
							bfr[ count ] = vc.normal.z;	count++;
						}else{
							bfr[ count ] = f.normal.x;	count++;
							bfr[ count ] = f.normal.y;	count++;
							bfr[ count ] = f.normal.z;	count++;
						}
						
					}
					else
					{
						bfr[ count ] = va.x;	count++;
						bfr[ count ] = va.y;	count++;
						bfr[ count ] = va.z;	count++;
						
						if(va.color >= 0) {
							_color = va.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						}
						
						bfr[ count ] = vb.x;	count++;
						bfr[ count ] = vb.y;	count++;
						bfr[ count ] = vb.z;	count++;
						
						if(vb.color >= 0) {
							_color = vb.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						}
						
						bfr[ count ] = vc.x;	count++;
						bfr[ count ] = vc.y;	count++;
						bfr[ count ] = vc.z;	count++;
						
						if(vc.color >= 0) {
							_color = vc.color;
							bfr [ count ] = (_color >> 16 & 255)/255; count++;  // r
							bfr [ count ] = (_color >> 8 & 255)/255; count++;   // g
							bfr [ count ] = (_color & 255)/255; count++;   // b
						}else{
							bfr [ count ] = prg.r;  count++;
							bfr [ count ] = prg.g;  count++;
							bfr [ count ] = prg.b;  count++;
						} 
					}
					
				}
			}
			
			currBuffer.ib.push( currBuffer.id, currBuffer.id+1, currBuffer.id+2 );
			
			if( ! prg.hideBackfaces ) 
			{
				currBuffer.ib.push( currBuffer.id+2, currBuffer.id+1, currBuffer.id );
			}
			
			currBuffer.id += 3;
		}
		
		public function upload (session:RenderSession) :void 
		{
			if(prg.tx) 
			{
				if(prg.lighting) 
				{
					vertexBuffer = session.context3d.createVertexBuffer(buffer.length/8, 8);
					vertexBuffer.uploadFromVector(buffer, 0, buffer.length/8);
				}
				else
				{
					vertexBuffer = session.context3d.createVertexBuffer(buffer.length/5, 5);
					vertexBuffer.uploadFromVector(buffer, 0, buffer.length/5);
				}
			}
			else
			{
				if( prg.a < 1 ) {
					if(prg.lighting) {
						vertexBuffer = session.context3d.createVertexBuffer(buffer.length/10, 10);
						vertexBuffer.uploadFromVector(buffer, 0, buffer.length/10);
					}else{
						vertexBuffer = session.context3d.createVertexBuffer(buffer.length/7, 7);
						vertexBuffer.uploadFromVector(buffer, 0, buffer.length/7);
					}
				}else{
					if(prg.lighting) {
						vertexBuffer = session.context3d.createVertexBuffer(buffer.length/9, 9);
						vertexBuffer.uploadFromVector(buffer, 0, buffer.length/9);
					}else{
						vertexBuffer = session.context3d.createVertexBuffer(buffer.length/6, 6);
						vertexBuffer.uploadFromVector(buffer, 0, buffer.length/6);
					}
				}
			}
			
			indexBuffer = session.context3d.createIndexBuffer(ib.length);
			indexBuffer.uploadFromVector(ib, 0, ib.length);
			
			if(subBuffer != null) {
				var L:int = subBuffer.length;
				for(var i:int = 0; i<L; i++) {
					subBuffer[i].upload( session );
				}
			}
		}
		
		public function draw (session:RenderSession) :void {
			
			var L:int;
			var i:int;
			var mb:MeshBuffer;
			var ctx:Object = session.context3d;
							
			if( session.currPrg != prg ) 
			{
				if(session.textures > 0) {
					// reset textures
					for (i=0; i<session.textures; i++) {
						ctx.setTextureAt( i, null );
					}
					session.textures = 0;
				}
				
				if(session.gpuBuffers > 0) {
					// reset vertex buffers
					for ( i=0; i<session.gpuBuffers; i++) {
						ctx.setVertexBufferAt ( i, null );
					}
					session.gpuBuffers = 0;
				}
				
				// Set material program
				session.currPrg = prg;
				ctx.setProgram( prg.program );
				
				
				// use transparency if required
				if( prg.a < 1 ) {
					if( session.gpuBlendMode != 1 ) {
						ctx.setBlendFactors("sourceAlpha","oneMinusSourceAlpha");
						session.gpuBlendMode = 1;
					}
				}else{
					if(session.gpuBlendMode != 0) {
						ctx.setBlendFactors("one","zero");
						session.gpuBlendMode = 0;
					}
				}
				
				if( prg.lighting ) 
				{
					var list:Vector.<SceneLight> = prg.lights.lightList;
					var light:SceneLight;
					var mt:Matrix3d;
					var index:int=2;
					
					
					vec8[0] = prg.lights._sar/255;
					vec8[1] = prg.lights._sag/255;
					vec8[2] = prg.lights._sab/255;
					
					vec8[4] = prg.diffuse;
					vec8[5] = prg.luminosity;
					ctx.setProgramConstantsFromVector("fragment", 0, vec8);
					
					L = list.length;
					for(var k:int=0; k<list.length; k++)
					{
						light = list[k];
						mt = light.transform.gv;
						
						if(light.directional) {
							
							vec4[0] = mt.i;	vec4[1] = mt.j;	vec4[2] = mt.k;
							ctx.setProgramConstantsFromVector("fragment", index, vec4 ); // Light ZAxis
							
						}else{
							vec4[0] = mt.m;	vec4[1] = mt.n;	vec4[2] = mt.o;
							ctx.setProgramConstantsFromVector("fragment", index, vec4 ); // Light Position
							
						}
						vec4[0] = light.r/255*light.intensity;
						vec4[1] = light.g/255*light.intensity;
						vec4[2] = light.b/255*light.intensity;
						ctx.setProgramConstantsFromVector("fragment", index+1, vec4);
						index += 2;
					}
				}
				
				if( prg.tx ) {
					ctx.setTextureAt( 0, prg._cTexture );
					session.textures++;
				}
			} // if program not set
			
			// Render all MeshBuffers
			
			ctx.setProgramConstantsFromVector("vertex", 0, so.viewVec);
			
			if( prg.tx ) 
			{
				/*if( ! prg._cTexture ) {
					return;
				}*/
				
				ctx.setVertexBufferAt( 0, vertexBuffer, 0, "float3" );
				ctx.setVertexBufferAt( 1, vertexBuffer, 3, "float2" );
				session.gpuBuffers = 2;
				
				if( prg.lighting ) {
					ctx.setProgramConstantsFromVector("vertex", 4, so.modelViewVec);
					ctx.setVertexBufferAt( 2, vertexBuffer, 5, "float3" );
					session.gpuBuffers++;
				}
				
				ctx.drawTriangles(indexBuffer);
				
				if(subBuffer != null) {
					L = subBuffer.length;
					for(i=0; i<L; i++) {
						mb = subBuffer[i];
						ctx.setVertexBufferAt( 0, mb.vertexBuffer, 0, "float3" );
						ctx.setVertexBufferAt( 1, mb.vertexBuffer, 3, "float2");
						if(prg.lighting) ctx.setVertexBufferAt( 2, mb.vertexBuffer, 5, "float3" );
						
						ctx.drawTriangles(mb.indexBuffer);
					}
				}
			}
			else
			{
				ctx.setVertexBufferAt( 0, vertexBuffer, 0, "float3" );
				ctx.setVertexBufferAt( 1, vertexBuffer, 3, (prg.a < 1 ? "float4" : "float3") );
				
				session.gpuBuffers = 2;
				
				if( prg.lighting ) 
				{
					ctx.setProgramConstantsFromVector("vertex", 4, so.modelViewVec);
					ctx.setVertexBufferAt( 2, vertexBuffer, (prg.a < 1 ? 7 : 6), "float3" );
					session.gpuBuffers++;
				}
				
				
				ctx.drawTriangles(indexBuffer);
				if(subBuffer != null) {
					L = subBuffer.length
					for(i=0; i<L; i++) {
						mb = subBuffer[i];
						ctx.setVertexBufferAt( 0, mb.vertexBuffer, 0, "float3" );
						ctx.setVertexBufferAt( 1, mb.vertexBuffer, 3, (prg.a < 1 ? "float4":"float3") );
						if( prg.lighting ) ctx.setVertexBufferAt( 2, mb.vertexBuffer, (prg.a < 1 ? 7 : 6), "float3" );
						ctx.drawTriangles(mb.indexBuffer);
					}
				}
			}
		}
		
		public function dispose () :void 
		{
			id = 0;
			if(vertexBuffer) vertexBuffer.dispose();
			if(indexBuffer) indexBuffer.dispose();
			if(subBuffer != null) {
				var L:int = subBuffer.length;
				for(var i:int=0; i<L; i++) {
					subBuffer[i].dispose();
				}
			}
			vertexBuffer = null;
			indexBuffer = null;
			
			buffer = new Vector.<Number>();
		}
		
	}

}
