package we3d.animation.modifier
{
	public interface IModifier {
		function evaluate (frame:Number, value:Number, kf:int, lkf:int) :Number;
	}
}