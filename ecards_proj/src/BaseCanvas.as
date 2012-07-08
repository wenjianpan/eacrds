package
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import mx.containers.Canvas;
	import gs.TweenLite;
	import gs.easing.*;
	import mx.controls.Alert;

	public class BaseCanvas extends Canvas
	{
		
		private var lastInfo:Dictionary;
		
		public function BaseCanvas()
		{
			lastInfo=new Dictionary();
		}
		
		public function recordInfo():void {
			lastInfo.x=this.x;
			lastInfo.y=this.y;
			lastInfo.scaleX=this.scaleX;
			lastInfo.scaleY=this.scaleY;
			lastInfo.rotation=this.rotation;
		}
		
		public function restoreInfo():void {
			this.x=lastInfo.x;
			this.y=lastInfo.y;
			this.scaleX=lastInfo.scaleX;
			this.scaleY=lastInfo.scaleY;
			this.rotation=lastInfo.rotation;
		}
		private var _big:Boolean;
		public function randomPos(data:Object):void {
			var initScaleX:Number;
			var initScaleY:Number;
			
			if(data == null) {
				 initScaleX = 0.3;
				 initScaleY = 0.3;
			} else {
			   initScaleX=Number(data.@["initScaleX"]);						
			   initScaleY=Number(data.@["initScaleY"]);
			}
			initScaleX = 0.4;
			initScaleY = 0.4;
			
			this.scaleX=initScaleX;
			this.scaleY=initScaleY;
			var parent:DisplayObjectContainer=this.parent;
			var tw:Number=parent.width-this.width*initScaleX;
			var th:Number=parent.height-this.height*initScaleY;
			this.x=Math.random()*tw;
			this.y=Math.random()*th;
			this.rotation=30 - 60*Math.random();
			this.recordInfo();
			_big=false;
		}
		
		public static const ToggleTime:Number=0.5;
		public function toggle():void {
			var parent:DisplayObjectContainer=this.parent;
			parent.setChildIndex(this,parent.numChildren-1);
			if(_big) {
				TweenLite.to(this, ToggleTime , {x:Number(lastInfo.x), y:Number(lastInfo.y), scaleX:Number(lastInfo.scaleX), scaleY:Number(lastInfo.scaleY), rotation:Number(lastInfo.rotation), ease:Circ.easeOut});
			} else {
				TweenLite.to(this, ToggleTime , {x:(parent.width-this.unscaledWidth)/2, y:(parent.height-this.unscaledHeight)/2, scaleX:1, scaleY:1, rotation:0, ease:Circ.easeOut});
			}
			_big=!_big;
		}
		
		public function get big():Boolean {
			return _big;
		}
		
	}
}