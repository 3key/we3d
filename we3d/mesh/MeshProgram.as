package we3d.mesh
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.material.BitmapAttributes;
	import we3d.material.BitmapLightAttributes;
	import we3d.material.FlatAttributes;
	import we3d.material.FlatLightAttributes;
	import we3d.material.ISurfaceAttributes;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;
	import we3d.scene.LightGlobals;
	import we3d.scene.SceneLight;

	use namespace we3d;
	
	
	/**
	 *	Mesh material for GPU rendering 
	 */ 
	public class MeshProgram
	{
		public function MeshProgram () :void {}
		
		// material properties
		we3d var hideBackfaces:Boolean=true;
		we3d var r:Number = 0.0;
		we3d var g:Number = 0.6;
		we3d var b:Number = 0.9;
		we3d var a:Number = 1.0;
		
		we3d var lighting:Boolean = false;
		we3d var luminosity:Number = 0;
		we3d var diffuse:Number = 1;
		
		we3d var bitmap:BitmapData = null;
		we3d var repeat:Boolean=true;
		
		we3d var tx:Boolean=false;
		we3d var lights:LightGlobals;
		
		/** @private  */
		we3d var _cTexture:Object=null;
		
		// agal objects
		private var agalVertex:AGALMiniAssembler;
		private var agalFragment:AGALMiniAssembler;
		public var program:Object;
		
		public function createTexture (session:RenderSession, bmp:BitmapData) :void 
		{
			if(session.context3d) {
				
				if(_cTexture != null) {
					_cTexture.dispose();
					_cTexture = null;
				}
				
				if(bmp != null && bmp.width > 0 && bmp.height > 0) 
				{	
					_cTexture = session.context3d.createTexture( bmp.width, bmp.height,/* Context3DTextureFormat.BGRA*/"bgra", false ); 
					_cTexture.uploadFromBitmapData( bmp );
				}
			}
		}
		
		
		public function setMaterial (f:Surface, session:RenderSession) :void 
		{
			if(session.context3d != null) 
			{
				// Create agal assembly for a Surface
				
				hideBackfaces = f.hideBackfaces;
				
				agalVertex = new AGALMiniAssembler();
				agalFragment = new AGALMiniAssembler();
				
				var agalVertexSource:String;
				var agalFragmentSource:String;
				
				var list:Vector.<SceneLight>;
				var L:int;
				var index:int;
				var light:SceneLight;
				var i:int;
				
				if(f.attributes is BitmapAttributes) 
				{
					tx = true;
					
					if( f.attributes is BitmapLightAttributes ) 
					{
						lighting = true;
						
						var bla:BitmapLightAttributes = BitmapLightAttributes(f.attributes);
						
						createTexture(session, bla._texture);
						
						lights = bla.lightGlobals;
						
						list = lights.lightList;
						L = list.length;
						
						a = bla._texture.transparent ? 0.5 : 1;
						
						luminosity = bla.luminosity;
						diffuse = bla.diffuse;
						
						if(  L == 0  ) 
						{
							agalVertexSource =
								"m44 op, va0, vc0 \n"  +
								"mov v0, va1 \n";
							agalFragmentSource = "tex oc, v0, fs0 <2d,repeat,linear> \n";
							
							lighting = false;
						}
						else
						{
							agalVertexSource = "m44 op, va0, vc0 \n"		// transform vertex
							agalVertexSource += "mov vt0, va2 \n";		
							agalVertexSource += "dp3 vt0.x, va2, vc4 \n"	// rotate normal
							agalVertexSource += "dp3 vt0.y, va2, vc5 \n"	// rotate normal
							agalVertexSource += "dp3 vt0.z, va2, vc6 \n"	// rotate normal
							agalVertexSource += "mov v0, va1 \n"; 			// uv to fragment
							agalVertexSource += "mov v1, vt0 \n"; 			// normal to fragment
							agalVertexSource += "m44 v2, va0, vc4 \n";		// vertex to world coord
							
							agalFragmentSource = "mov ft2, fc0 \n"; 		// set ambient light
							index=2;
							
							for(i=0; i<L; i++) 
							{
								light = list[i];
								
								if(light.directional) 
								{
									agalFragmentSource += "dp3 ft0, fc"+index+", v1 \n"; 	// angle(ft0) = light-zaxis(fc2) * normal(v1)
									agalFragmentSource += "neg ft0, ft0 \n"; 				// negate angle
								}
								else
								{
									// point light
									agalFragmentSource += "sub ft0, fc"+index+", v2 \n"; 	// tmp = lightpos - vertex
									agalFragmentSource += "nrm ft0.xyz, ft0 \n"; 
									agalFragmentSource += "dp3 ft0, ft0, v1 \n";
								}
								
								agalFragmentSource += "mul ft1, ft0, fc"+(index+1)+" \n"; 	// tmp(ft1) = angle(ft0) * lightcolor(fc3)
								agalFragmentSource += "add ft2.xyz, ft2, ft1 \n"; 				// add single lightcolor to alllightscolor
								
								index += 2;
							} // for lights
							
							agalFragmentSource += "sat ft2, ft2, \n"; 			// clamp
							agalFragmentSource += "tex ft1, v0, fs0 <2d,repeat,linear> \n" ; // get pixel color
							agalFragmentSource += "mul ft3, ft1, fc1.y \n"; 	// calc luminosity
							agalFragmentSource += "mul ft4, ft1, ft2 \n"; 		// tmp(ft4) =  pixelcolor(ft1) * alllightscolor(ft2)
							
							agalFragmentSource += "mul ft4.xyz, ft4, fc1.x \n"; 	// multiply final color with diffuse
							agalFragmentSource += "add ft4.xyz, ft4, ft3 \n"; 		// add luminosity
							agalFragmentSource += "sat oc, ft4, \n"; 			// clamp
						}
						
					}
					else
					{
						lighting = false;
						
						var ba:BitmapAttributes = BitmapAttributes(f.attributes);
						createTexture( session, ba._texture );
						
						a = ba._texture.transparent ? 0.5 : 1;
						
						agalVertexSource =
							"m44 op, va0, vc0 \n"  +
							"mov v0, va1 \n";
						agalFragmentSource =
							"tex oc, v0, fs0 <2d,repeat,linear> \n";
					}
				}
				else
				{
					tx = false; 
					
					if(f.attributes is FlatLightAttributes ) 
					{
						lighting = true;
						
						var fla:FlatLightAttributes = FlatLightAttributes(f.attributes);
						lights = fla.lightGlobals;
						list = lights.lightList;
						L = list.length;
						
						r = fla.r; g = fla.g; b = fla.b;
						a = fla._alpha;
						
						luminosity = fla.luminosity;
						diffuse = fla.diffuse;
						
						if(  L == 0  ) 
						{
							agalVertexSource = "m44 op, va0, vc0 \nmov v0, va1 \n";
							agalFragmentSource = "mov oc, v0 \n";
							lighting = false;
						}
						else
						{
							agalVertexSource = "m44 op, va0, vc0 \n"		// output screen vertex
							agalVertexSource += "mov vt0, va2 \n";
							
							agalVertexSource += "dp3 vt0.x, va2, vc4 \n"		// rotate normal
							agalVertexSource += "dp3 vt0.y, va2, vc5 \n"		// rotate normal
							agalVertexSource += "dp3 vt0.z, va2, vc6 \n"		// rotate normal
								
							agalVertexSource += "mov v0, va1 \n"; 			// color to fragment
							agalVertexSource += "mov v1, vt0 \n"; 			// normal to fragment
							agalVertexSource += "m44 v2, va0, vc4 \n";		// vertex to world coord	
							
							agalFragmentSource = "mov ft2, fc0 \n"; 		// set ambient light
							
							index = 2;
							
							for(i=0; i<L; i++) 
							{
								light = list[i];
								
								if(light.directional) 
								{
									agalFragmentSource += "dp3 ft0, fc"+index+", v1 \n"; 	// angle(ft0) = light-zaxis(fc2) * normal(v1)
									agalFragmentSource += "neg ft0, ft0 \n"; 				// negate angle
								}
								else
								{
									// point light
									agalFragmentSource += "sub ft0, fc"+index+", v2 \n"; 	// tmp = lightpos - vertex
									agalFragmentSource += "nrm ft0.xyz, ft0 \n"; 			// normalize tmp
									agalFragmentSource += "dp3 ft0, ft0, v1 \n";			// angle(ft0) = direction(ft0) * normal(v1)
								}
								
								agalFragmentSource += "mul ft1, ft0, fc"+(index+1)+" \n"; 	// tmp(ft1) = angle(ft0) * lightcolor(fc3)
								agalFragmentSource += "add ft2.xyz, ft2, ft1 \n"; 				// add lightcolor to alllightscolor
								
								index += 2;
							} // for lights
							
							agalFragmentSource += "sat ft2, ft2, \n"; 			// clamp
							agalFragmentSource += "mul ft3, v0, fc1.y \n"; 	// calc luminosity
							agalFragmentSource += "mul ft4, v0, ft2 \n"; 		// tmp(ft4) = facecolor(v0)* alllightscolor(ft2)
							agalFragmentSource += "mul ft4.xyz, ft4, fc1.x \n"; 	// multiply final color with diffuse
							agalFragmentSource += "add ft4.xyz, ft4, ft3 \n"; 		// add luminosity
							agalFragmentSource += "sat oc, ft4, \n"; 			// clamp
						}
					}
					else
					{
						lighting = false;
						
						// single solid color
						
						agalVertexSource = "m44 op, va0, vc0 \nmov v0, va1 \n";
						agalFragmentSource = "mov oc, v0 \n";
						
						var fa:FlatAttributes = FlatAttributes(f.attributes);
						r = fa.r;
						g = fa.g;
						b = fa.b;
						a = fa._alpha;
					}
				}
				
				agalVertex.assemble( "vertex", agalVertexSource );
				agalFragment.assemble( "fragment", agalFragmentSource );
				
				program = session.context3d.createProgram();
				program.upload( agalVertex.agalcode, agalFragment.agalcode );
			}
		}
		
		public function dispose () :void 
		{
			if(program) program.dispose();
			if(_cTexture) _cTexture.dispose();
			program = null;
			_cTexture = null;
		}
	}
}