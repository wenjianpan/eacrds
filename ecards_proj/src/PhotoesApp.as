package
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	import gs.easing.*;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.controls.Alert;

	public class PhotoesApp extends Application
	{
				
		protected const dropShadow:DropShadowFilter=new DropShadowFilter(0, 45, 0x333333, 0.8, 10, 10, 2, 3);
		private var photoes:Array=new Array();
		private var index:int = 0;
		
		public var editor:PhotoEdit = new PhotoEdit();
		public var letterPaper:Letter = new Letter();
		
		public function PhotoesApp()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onLoadData);
		}

		protected function onLoadData(e:Event):void {
			this.removeEventListener(FlexEvent.CREATION_COMPLETE,onLoadData);
			loadData();
		}
		
		protected function loadData():void {
			var obj:Object=this;			
			var photoes:XML=XML(obj.testData[0]);
			if(root==null || this.width<2 || this.height<2) {
				setTimeout(loadData,50);
			} else {
				/*
				var str:String=null;
				try {
					str=String(root.loaderInfo.parameters.photoes);
				} catch (e:Error) {
					//how to do?
				}
				if(str!=null && str.length>0) */ {
					// var photoes:XML=XML(str);
					for each(var photo:XML in photoes.children()) {
						processModel(photo,photoes);
						addPhoto(photo);
					}
				}
			}
			
			this.addChild(editor);
			canDrag(editor);
			editor.x = 80;
			editor.y = 40;
			
			this.addChild(letterPaper);
			canDrag(letterPaper);
			letterPaper.visible = false;
			letterPaper.x = editor.imgX;
			letterPaper.y = editor.imgY;
			letterPaper.scaleX = 0.9;
			letterPaper.scaleY = 0.9;
		}
		
		protected function canDrag(e:DisplayObject):void {
			e.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			e.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			e.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			e.filters=[dropShadow];
		}
		
		protected function cancelDrag(e:DisplayObject):void {
			e.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			e.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			e.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private var dragTarget:DisplayObject;
		private var startPos:Point=new Point();
		private var startPoint:Point=new Point();
		private var dragEnabled:Boolean=true;
		protected function onMouseDown(e:MouseEvent):void {
			if(!dragEnabled) {
				return;
			}
			dragTarget=e.target as DisplayObject;
			while(dragTarget!=null && dragTarget.parent!=this) {
				dragTarget=dragTarget.parent;
			}
			dragTarget=dragTarget as BaseCanvas; 				
			if(dragTarget!=null) {
				startPos.x=dragTarget.x;
				startPos.y=dragTarget.y;
				startPoint.x=stage.mouseX;
				startPoint.y=stage.mouseY;
				this.setChildIndex(dragTarget,this.numChildren-1);					
			}
		}
		
		protected function onMouseUp(e:MouseEvent):void {
			if(dragTarget!=null) {
				var c:BaseCanvas=dragTarget as BaseCanvas;
				if(!c.big) {
					c.recordInfo();
				}
			}
			if(dragTarget is PhotoFrame) {
				if(stage.mouseX > (editor.x+ editor.imgX) && stage.mouseX < (editor.x+ editor.imgX+ editor.imgW)
				   && stage.mouseY > (editor.x + editor.imgY) && stage.mouseY < (editor.y + editor.imgY+ editor.imgH)) {
			        index=photoes.indexOf(dragTarget as Object); 
			        editor.loadPhoto(photoes[index] as PhotoFrame); 
			    }
			}
			dragTarget=null;
		}
		
		protected function onMouseMove(e:MouseEvent):void {
			if(!dragEnabled) {
				return;
			}
			if(dragTarget!=null) {
				dragTarget.x=startPos.x+stage.mouseX-startPoint.x;
				dragTarget.y=startPos.y+stage.mouseY-startPoint.y;					
			}
		}
		
		protected function onDoubleClick(e:MouseEvent):void {
		  index=photoes.indexOf(e.currentTarget as Object); 
		  
		  //Alert.show(index.toString(), 'Alert Box', mx.controls.Alert.OK); 
			editor.loadPhoto(photoes[index] as PhotoFrame);
		}
		
		public static const InitScaleX:Number=0.3;
		public static const InitScaleY:Number=0.3;
		public static const InitFontSize:Number=36;
		
		private function getNumber(o:Object,p:String):Number {
			return Number(o.@[p]);
		}
		
		protected function processModel(data:Object,parent:Object):void {
			var n:Number;
			var key:String;
			
			key="initScaleX";
			n=getNumber(data,key);
			if(isNaN(n) || n<=0 || n>1) {
				n=getNumber(parent,key);
				if(isNaN(n) || n<=0 || n>1) {
					n=InitScaleX;
				}
			}
			data.@[key]=n;
			
			key="initScaleY";
			n=getNumber(data,key);
			if(isNaN(n) || n<=0 || n>1) {
				n=getNumber(parent,key);
				if(isNaN(n) || n<=0 || n>1) {
					n=InitScaleY;
				}
			}
			data.@[key]=n;
			
			key="initFontSize";
			n=getNumber(data,key);
			if(isNaN(n) || n<=0) {
				n=getNumber(parent,key);
				if(isNaN(n) || n<=0) {
					n=InitFontSize;
				}
			}
			data.@[key]=n;
			
			key="displayMethod";
			var s:String;
			s=data.@[key];
			if(s==null || s.length<1) {
				s=parent.@[key];
			}
			data.@[key]=s;				
			
		}
		
		protected function addPhoto(data:Object):void {
			var photo:PhotoFrame=new PhotoFrame();
			this.addChild(photo);
			canDrag(photo);
			photo.randomPos(data);
			photo.addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick);
			photoes.push(photo);
		}
		
		public function addLocalPhoto(data:Object):void {
			
			//Alert.show("Fuck2!!");
			
			var photo:PhotoFrame=new PhotoFrame();
			photo.isLocal = true;
			this.addChild(photo);
			canDrag(photo);
			photo.randomPos2(data);
			photo.addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick);
			photoes.push(photo);
		}
		
		public function doNext(c:Object):void {
				var len:int=photoes.length;
				if(index>=0 && len>1) {
					index++;
					if(index>=len) {
						index=0;
					}
					(c as PhotoEdit).loadPhoto(photoes[index] as PhotoFrame);
				}
		}			
		
		public function doPrevious(c:Object):void {
				var len:int=photoes.length;
				if(index>=0 && len>1) {
					index--;
					if(index<0) {
						index=len-1;
					}
					(c as PhotoEdit).loadPhoto(photoes[index] as PhotoFrame);
				}
		}
		
		private var lastPos:Point=new Point();
		private var lastWidth:int;
		private var lastHeight:int;
		private var big:Boolean = true;
		
		public function doToggle(c:Object):void {
			var hTarget:DisplayObject = c as DisplayObject;
			var r:int = 30 - 60*Math.random();
			var x:int = Math.random()*800;
			var y:int = Math.random()*640;
			
			while(hTarget!=null && hTarget.parent!=this) {
				hTarget=hTarget.parent;
			}
			
			if(big) {
			  lastPos.x = hTarget.x;
			  lastPos.y = hTarget.y;
			  lastWidth = hTarget.width;
			  lastHeight = hTarget.height;
			  
				TweenLite.to(hTarget, 0.6, {x:x, y:y, scaleX:0.5, scaleY:0.5, rotation:r}); 	
				big = false;
			}
			else {  
			  TweenLite.to(hTarget, 0.6, {x:lastPos.x, y:lastPos.y, scaleX:1, scaleY:1, rotation:0});
			  big = true;
			} 
		}
		
		public function doCreateLetter(o:PhotoEdit):void 
		{   	        

      this.setChildIndex((letterPaper as DisplayObject),this.numChildren-1);
      letterPaper.visible = true;
      letterPaper.image.source = o.copyImage();
      
      letterPaper.image.x = 100;
      letterPaper.image.y = 25;
      letterPaper.image.width = 310;
      letterPaper.image.height = 253;
      	  
		}
		
    public function doHideLetter():void 
    {
      //this.setChildIndex((letterPaper as DisplayObject),this.numChildren-1);
      letterPaper.visible = false;
    }
	}
}

