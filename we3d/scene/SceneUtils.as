package we3d.scene
{
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.core.transform.Transform3d;
	import we3d.scene.Scene3d;

	use namespace we3d;
	
	public class SceneUtils 
	{
		/**
		* Sorts the objectList of a scene for parenting hierarchies 
		* @param	s	the scene to prepare
		*/
		public static function sortScene (s:Scene3d) :void {
			s.objectList = sortHierarchy(s.objectList);
		}
		
		/**
		* Sorts the objectList of a scene for parenting hierarchies 
		* @param	a	the array to sort
		* @return the sorted array as a new array
		*/
		public static function sortHierarchy (a:Vector.<Object3d>) :Vector.<Object3d> {
			
			var r:Vector.<Object3d> = new Vector.<Object3d>();
			var dp:Array = new Array();
			
			var p:Transform3d;
			var e:int = 0;
			var i:int;
			var j:int;
			var L:int = a.length;
			
			for(i=0; i<L; i++) {
				if(a[i] is Object3d) {
					p = a[i].transform._parent;
					
					if(p == null) {
						r.push(a[i]);
					}else{
						e = 0;
						while (p) {
							e++;
							p = p._parent;
						}
						if(dp[e] is Array) {
							dp[e].push(a[i]);
						}else{
							dp[e] = [a[i]];
						}
					}
				}
			}
			
			L = dp.length;
			var L2:int;
			for(i=0; i<L; i++) {
				if(dp[i] is Array) {
					L2 = dp[i].length;
					for(j=0; j<L2; j++) {
						r.push(dp[i][j]);
					}
				}
			}
			
			return r;
		}
	}
}