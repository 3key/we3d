package we3d.scene.dynamics 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import we3d.we3d;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* The ParticleSpriteRenderer renders a 2D (Flash) Sprite at every point. The Sprites are not scaled with 3D perspective. 
	* All clips have to be linked in the library to be able to be instanciated. 
	*/ 
	public class ParticleSpriteRenderer extends ParticleRenderer 
	{
		public function ParticleSpriteRenderer (...clips:Array) 
		{
			var list:Array;
			if(clips[0] is Array) list = clips[0];
			else list = clips;
			
			if(list.length > 0) {
				addClipTemplate(list);
			}
		}
		
		public var randomClip:Boolean = true;
		
		private var clipTemplates:Vector.<Object> = new Vector.<Object>();
		private var clipTemplateLength:int=0;
		
		private var lastClipId:int=0;
		private var sprites:Vector.<DisplayObject>=new Vector.<DisplayObject>();
		
		public function clearAllTemplates () :void {
			clipTemplates = new Vector.<Object>();
			clipTemplateLength=0;
		}
		
		public function addClipTemplate (...clips:Array) :void 
		{
			var list:Array; if(clips[0] is Array) list = clips[0]; else list = clips;
			
			for(var i:int=0; i<list.length; i++) 
			{
				if( list[i] is Bitmap ) {
					clipTemplates.push( list[i] );
					continue;
				}
				
				try{
					var def:Object = getDefinitionByName( getQualifiedClassName( list[i] ) );
					clipTemplates.push( def );
				}catch(e:Error){
					trace("The clip " + list[i] + " can not be instanciated");
				}
			}
		}
		
		public override function render (emt:ParticleEmitter, session:RenderSession) :void 
		{
			var L:int = emt.points.length;
			var tL:int = clipTemplates.length;
			var p:Particle;
			var clp:DisplayObject;
			var ofc:int = emt.so.frameCounter;
			
			if(randomClip) 
			{
				var o:Object;
				
				for(var i:int=0; i<L; i++) 
				{
					p = emt.points[i];
					
					if(p.frameCounter2 == ofc) 
					{
						if( p.clipRef[session.viewId] == null ) 
						{
							lastClipId = Math.random() * tL;
							o = clipTemplates[lastClipId];
							if( o is Bitmap) {
								clp = new Bitmap(Bitmap(o).bitmapData);
							}else{
								clp = new o();
							}
							if(p.size != 0)
								clp.scaleX = clp.scaleY = p.size;
							
							p.clipRef[session.viewId] = clp;
							
							session.container.addChild( clp );
						}
						else
						{
							clp = DisplayObject(p.clipRef[session.viewId]);
						}
						
						clp.alpha = p.alpha;
						clp.visible = true;
						clp.x = p.sx;
						clp.y = p.sy;
					}
					else
					{
						if(p.clipRef[session.viewId]) {
							DisplayObject(p.clipRef[session.viewId]).visible = false;
						}
					}
				}
				
			}else{
				
				lastClipId++;
				
			}
		}
		public override function clone () :ParticleRenderer {
			return new ParticleSpriteRenderer();
		}
	}
}