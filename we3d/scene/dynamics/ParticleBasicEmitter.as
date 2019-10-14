package we3d.scene.dynamics 
{
	import flash.events.TimerEvent;
	
	import we3d.we3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* @private
	*/
	public class ParticleBasicEmitter extends ParticleEmitter
	{
		public function ParticleBasicEmitter () {}
				
		public override function tick(e:TimerEvent) :void 
		{
			var i:int;
			var p:Particle;
			
			so.objectCuller.reset();
			
			// increase age and kill if to old
			for(i=points.length-1; i>=0; i--) {
				p = points[i];
				p.age++;
				if( p.age >= p.lifeTime ) {
					p.die();
					points.splice(i,1);
				}else{
					so.objectCuller.testPoint(p.x, p.y, p.z);
					updatePhysics(p);
				}
			}
			
			var L:int = points.length;
			
			// Generate new particles per tick
			if( L < particleLimit ) 
			
			{
				var pl:int = generatePerTick;
				if( L + generatePerTick > particleLimit ) pl = particleLimit - L; 
				
				for(i=0; i<pl; i++) {
					createParticle();
				}
			}
		}
		
		private function updatePhysics ( p:Particle, dt:Number=1 ) :void 
		{
			p.forces_x = gravity.x * p.weight;
			p.forces_y = gravity.y * p.weight;
			p.forces_z = gravity.z * p.weight;
			
			var dragX:Number = -p.velocity_x;
			var dragY:Number = -p.velocity_y;
			var dragZ:Number = -p.velocity_z;
			var m:Number = Math.sqrt(dragX*dragX + dragY*dragY + dragZ*dragZ);
			dragX /= m;	dragY/=m;	dragZ/=m;
			
			m = m*m;
			
			p.forces_x += dragX * m * p.resistance;
			p.forces_y += dragY * m * p.resistance;
			p.forces_z += dragZ * m * p.resistance;
			
			// ... wind ...
			
			var aeX:Number = p.forces_x * p.invWeight;
			var aeY:Number = p.forces_y * p.invWeight;
			var aeZ:Number = p.forces_z * p.invWeight;
			
			p.velocity_x += aeX * dt;
			p.velocity_y += aeY * dt;
			p.velocity_z += aeZ * dt;
			
			p.x += p.velocity_x * dt;
			p.y += p.velocity_y * dt;
			p.z += p.velocity_z * dt;
		}
		
		private function createParticle () :Particle {
			
			var randCol:int;
			var rc:int;
			var gc:int;
			var bc:int;
			
			if(constrainRandomColor) 
			{
				if(randomColor > 0) 
				{					
					rc = color >> 16 & 255;
					gc = color >> 8 & 255;
					bc = color & 255;
					
					var rn:Number = Math.random()*randomColor;
					
					rc *= rn;
					gc *= rn;
					bc *= rn;
					
					if(rc > 255) rc=255;
					if(gc > 255) gc=255;
					if(bc > 255) bc=255;
					
					randCol = int(rc) << 16 | int(gc) << 8 | int(bc);
				}
				else
				{
					randCol = color;
				}
			}
			else
			{
				if(randomRed > 0 || randomGreen > 0 || randomBlue > 0) 
				{
					rc = color >> 16 & 255;
					gc = color >> 8 & 255;
					bc = color & 255;
					
					rc += Math.random()*randomRed;
					gc += Math.random()*randomGreen;
					bc += Math.random()*randomBlue;
					
					if(rc > 255) rc=255;
					if(gc > 255) gc=255;
					if(bc > 255) bc=255;
					
					randCol = int(rc) << 16 | int(gc) << 8 | int(bc);
				}
				else
				{
					randCol = color;
				}
				
			}
		
			
			var p:Particle = new Particle(  weight     + Math.random()*randomWeight,
											resistance + Math.random()*randomResistance,
											lifeTime   + Math.random()*randomLifeTime, 
											particleSize + Math.random()*randomParticleSize, 
											explosion   +  Math.random()*randomExplosion,
											randCol, 
											alpha + Math.random()*randomAlpha);
			initPosition( p );
			
			if(p.explosion != 0) 
			{	
				p.velocity_x = p.x-(center.x + so.transform.gv.m);
				p.velocity_y = p.y-(center.y + so.transform.gv.n);
				p.velocity_z = p.z-(center.z + so.transform.gv.o);
				
				var d:Number = Math.sqrt(p.velocity_x*p.velocity_x + p.velocity_y*p.velocity_y + p.velocity_z*p.velocity_z);
				p.velocity_x /= d;
				p.velocity_y /= d;
				p.velocity_z /= d;
				
				p.velocity_x *= p.explosion;
				p.velocity_y *= p.explosion;
				p.velocity_z *= p.explosion;
			}
			
			p.velocity_x += velocity_x + so.velocity_x;
			p.velocity_y += velocity_y + so.velocity_y;
			p.velocity_z += velocity_z + so.velocity_z;
			
			points.push(p);
			return p;
		}
		
		private function initPosition (p:Particle) :void {
			
			var rx:Number = Math.random();
			var ry:Number = Math.random();
			var rz:Number = Math.random();
			var rp:Number;
			var fc:Face;
			
			if( nozzle == "box" ) {
				 
				p.x = rx * size.x -size.x/2;
				p.y = ry * size.y -size.y/2;
				p.z = rz * size.z -size.z/2;
				
			}else if( nozzle == "sphere" ) {
				var dx:Number = Math.sqrt(rx*rx+ry*ry+rz*rz);
				rx*= Math.random() >= 0.5 ? 1 : -1;	ry*= Math.random() >= 0.5 ? 1 : -1;	rz*= Math.random() >= 0.5 ? 1 : -1;
				p.x = (rx/dx)*(size.x);
				p.y = (ry/dx)*(size.y);
				p.z = (rz/dx)*(size.z);
			}else if( nozzle == "vertices" ) {
				if(so.points.length > 0) {
					rp = int(rx*(so.points.length-1));
					p.x = so.points[rp].x;
					p.y = so.points[rp].y;
					p.z = so.points[rp].z;
				}
			}else if( nozzle == "normal" ) {
				if( so.polygons.length > 0 ) {
					fc = so.polygons[ int(rx*(so.polygons.length-1)) ];
					p.x = fc.ax;
					p.y = fc.ay;
					p.z = fc.az;
					
					var velocityScale:Number = Math.sqrt(velocity_x*velocity_x + velocity_y*velocity_y + velocity_z*velocity_z);
					p.velocity_x = fc.normal.x * velocityScale;
					p.velocity_y = fc.normal.y * velocityScale;
					p.velocity_z = fc.normal.z * velocityScale;
				}
			}else if( nozzle == "surface" ) {
				if(so.points.length > 0 && so.polygons.length > 0) {
					if( so.polygons.length > 0 ) {
						var rf:int = Math.round(rx * (so.polygons.length-1));
						fc = so.polygons[rf];
						rp = int(ry*(fc.vLen-1));
						var rnd:Number = rz;
						p.x = fc.ax+(fc.vtxs[rp].x-fc.ax)*rnd;
						p.y = fc.ay+(fc.vtxs[rp].y-fc.ay)*rnd;
						p.z = fc.az+(fc.vtxs[rp].z-fc.az)*rnd;
					}
				}
			}
			
			var x:Number = p.x;
			var y:Number = p.y;
			var z:Number = p.z;
			var mt:Matrix3d = so.transform.gv;
			
			p.z = mt.c*x + mt.g*y + mt.k*z + mt.o;
			p.y = mt.b*x + mt.f*y + mt.j*z + mt.n;
			p.x = mt.a*x + mt.e*y + mt.i*z + mt.m;
			
		}
		
		public override function clone () :ParticleEmitter {
			var r:ParticleBasicEmitter = new ParticleBasicEmitter();
			r.copyFrom(this);
			return r;
		}
	
	}
}
