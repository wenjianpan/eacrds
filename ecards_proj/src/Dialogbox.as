/*
  www.ecardapps.com
  
  Panwenjian 2009.11.26
  First edition
*/

package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import mx.managers.CursorManager;
	
	import mx.controls.Alert;   // for debug

	public class Dialogbox extends Sprite 
	{
		protected const RESIZE_RECT_WIDTH: int = 8;
		protected const ATTACH_RECT_WIDTH: int = 16;
		
    protected const ATTACH_LENGTH: int = 20;
    
		// window output
	
		protected var size: Point;
		protected var rect: Rectangle;
		protected var resizeRect0: Rectangle;
		protected var resizeRect1: Rectangle;
		protected var resizeRect2: Rectangle;
		protected var resizeRect3: Rectangle;
		protected var attachRect:  Rectangle; 
		protected var closeRect:   Rectangle;  
		protected var attachPoint: Point;      // attach point
		
		protected var resizeSpr0: Sprite;
		protected var resizeSpr1: Sprite;
		protected var resizeSpr2: Sprite;
		protected var resizeSpr3: Sprite;
		protected var attachSpr:  Sprite;
		protected var closeSpr:   Sprite;    
		
		protected var minSize: Point = null;
		
		protected var centerPoint: Point;
		protected var point:Point; 

		// properties
		protected var bkColor: uint = 0xffffff;   
		protected var resizable: Boolean = false;
		
		private var _math:MathClass = new MathClass();

    private var field:TextField;
    private var _txtFieldXY: Point = new Point();
    private var _txtW: int = 0;
    private var _txtH: int = 0;

    /*
     * cusor managerment
     */

    [Bindable]
    [Embed(source="assets/atp.png")]
    private var atpIcon:Class;

    [Bindable]
    [Embed(source="assets/a0.png")]
    private var a0Icon:Class;

    [Bindable]
    [Embed(source="assets/a1.png")]
    private var a1Icon:Class;
    
    [Bindable]
    [Embed(source="assets/a2.png")]
    private var a2Icon:Class;

    [Bindable]
    [Embed(source="assets/a3.png")]
    private var a3Icon:Class;
    
    [Bindable]
    [Embed(source="assets/close.png")]
    private var closeIcon:Class;
        
    private var cursorID:int;
        
		/**
		 * Construction
		 * 
		 * Inherited classes should define at least these
		 * properties. 
		 */
		public function Dialogbox( aSize: Point, spt: Point, apt: Point, isResizable: Boolean = false )
		{
			//mgr =  aWindowManager;
			size = aSize;
			resizable = isResizable;
			minSize = new Point(70,  50);    // these value must > ATTACH_LENGTH*2
			attachPoint = new Point();
			centerPoint = new Point();
			
			this.x = spt.x;
			this.y = spt.y;
			rect = new Rectangle();
			resizeRect0 = new Rectangle();
			resizeRect1 = new Rectangle();
			resizeRect2 = new Rectangle();
			resizeRect3 = new Rectangle();
			attachRect = new Rectangle();
			closeRect = new Rectangle();
			
		  resizeSpr0 = new Sprite();
		  resizeSpr1 = new Sprite();
		  resizeSpr2 = new Sprite();
		  resizeSpr3 = new Sprite();
		  attachSpr = new Sprite();	
		  closeSpr = new Sprite();		
      addChild(resizeSpr0);
      addChild(resizeSpr1);
      addChild(resizeSpr2);
      addChild(resizeSpr3);
      addChild(attachSpr);
      addChild(closeSpr);
		
		var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0x0;
            format.size = 10;
            format.bold = true;
	
			// add text field
			field = new TextField( );
			field.type = TextFieldType.INPUT;
      field.defaultTextFormat = format;
      field.text = "Input here";
      
      field.addEventListener(FocusEvent.FOCUS_IN, clearTextField);

      //field.border = true;
      //field.background = true;
      field.wordWrap = true;

      addChild( field );
      
      var shadow:DropShadowFilter = new DropShadowFilter(alpha=0.8);
      shadow.distance = 8;
      shadow.angle = 25;

      this.filters = [shadow];      
      
      resizeSpr0.addEventListener(MouseEvent.MOUSE_OVER, moveOverRect0);
			resizeSpr0.addEventListener(MouseEvent.MOUSE_OUT, moveOutRect0);
			resizeSpr1.addEventListener(MouseEvent.MOUSE_OVER, moveOverRect1);
			resizeSpr1.addEventListener(MouseEvent.MOUSE_OUT, moveOutRect1);
			resizeSpr2.addEventListener(MouseEvent.MOUSE_OVER, moveOverRect2);
			resizeSpr2.addEventListener(MouseEvent.MOUSE_OUT, moveOutRect2);
			resizeSpr3.addEventListener(MouseEvent.MOUSE_OVER, moveOverRect3);
			resizeSpr3.addEventListener(MouseEvent.MOUSE_OUT, moveOutRect3);
			attachSpr.addEventListener(MouseEvent.MOUSE_OVER, moveOverAtpr);
			attachSpr.addEventListener(MouseEvent.MOUSE_OUT, moveOutAtpr);
			closeSpr.addEventListener(MouseEvent.MOUSE_OVER, moveOverCloseSpr);
			closeSpr.addEventListener(MouseEvent.MOUSE_OUT, moveOutCloseSpr);
			
			updateRects(apt.x, apt.y);
			paint();
		}

        [Bindable]
        private var textColor:int = 0x666666;
        private var edited:Boolean = false;
        private function clearTextField(e:Event) : void {
           textColor = 0; 
           if(edited == false) {
             field.text = "";
             field.htmlText = "";
             edited = true;
           }
        }
        
    private var _oldxy: Point = new Point();
    private var _oldapxy: Point = new Point();
    
		private function checkAndSetSize( aNewSize: Point): Boolean
		{
			var retx: Boolean = true;
			var rety: Boolean = true;
      
			// check size constraints
			if( aNewSize.x < getMinimumSize().x )
			{
				aNewSize.x = getMinimumSize().x;
				retx = false;
				this.x = _oldxy.x;
				attachPoint.x = _oldapxy.x;
			}
			
			if( aNewSize.y < getMinimumSize().y )
			{
				aNewSize.y = getMinimumSize().y;
				rety = false;
				this.y = _oldxy.y;
				attachPoint.y = _oldapxy.y;
			}
			
			size.x = aNewSize.x;
			size.y = aNewSize.y;
			updateInternals();

			return retx && rety;
		}
	  
		public function resize( sizeAmount: Point , pidx:int): Boolean
		{
		  var newSize: Point = new Point();
		  _oldxy.x = this.x;
		  _oldxy.y = this.y;
		  _oldapxy.x = attachPoint.x;
		  _oldapxy.y = attachPoint.y;
		  
		  if(pidx < 0) {
		     Alert.show("error");
		     return false;
		  } else if(pidx == 0) {
		     if(attachPoint.x < this.x) {
		        attachPoint.x += sizeAmount.x;
		     }
		     if(attachPoint.y < this.y) {
		        attachPoint.y += sizeAmount.y;
		     }
		  
		     this.x += sizeAmount.x;
		     this.y += sizeAmount.y;
		     newSize.x = size.x - sizeAmount.x;
		     newSize.y = size.y - sizeAmount.y;
		  } else if(pidx == 1) {
		     if(attachPoint.x > rect.right) {
		        attachPoint.x += sizeAmount.x;
		     }
		     if(attachPoint.y < this.y) {
		        attachPoint.y += sizeAmount.y;
		     }
		     
		     this.y += sizeAmount.y;
		     newSize.x = size.x + sizeAmount.x;
		     newSize.y = size.y - sizeAmount.y;
		  } else if(pidx == 2) {
		     if(attachPoint.x > rect.right) {
		        attachPoint.x += sizeAmount.x;
		     }
		     if(attachPoint.y > rect.bottom) {
		        attachPoint.y += sizeAmount.y;
		     }
		     
		     newSize.x = size.x + sizeAmount.x;
		     newSize.y = size.y + sizeAmount.y;
		  } else if(pidx == 3) {
		     if(attachPoint.x < this.x) {
		        attachPoint.x += sizeAmount.x;
		     }
		     if(attachPoint.y > rect.bottom) {
		        attachPoint.y += sizeAmount.y;
		     }
		     
		     this.x += sizeAmount.x;
		     newSize.x = size.x - sizeAmount.x;
		     newSize.y = size.y + sizeAmount.y;
		  }
		  
			return checkAndSetSize( newSize );  // 'newSize' is new size
		}
		
		private var savedPt:Point = new Point();
		
		public function moveAttachPoint(sizeAmount: Point): Boolean 
		{  
		   savedPt.x = attachPoint.x;
		   savedPt.y = attachPoint.y;
		   attachPoint.x += sizeAmount.x;
		   attachPoint.y += sizeAmount.y;
		   
		   if(rect.contains( attachPoint.x-ATTACH_RECT_WIDTH/2, attachPoint.y-ATTACH_RECT_WIDTH/2) ||
		      rect.contains( attachPoint.x-ATTACH_RECT_WIDTH/2, attachPoint.y+ATTACH_RECT_WIDTH/2) || 
		      rect.contains( attachPoint.x+ATTACH_RECT_WIDTH/2, attachPoint.y-ATTACH_RECT_WIDTH/2) ||
		      rect.contains( attachPoint.x+ATTACH_RECT_WIDTH/2, attachPoint.y+ATTACH_RECT_WIDTH/2) ) {
		       attachPoint.x = savedPt.x;
		       attachPoint.y = savedPt.y;
		       return false;
       }
       updateInternals();
       return true;
		}
		
		private function updateInternals(): void
		{
			updateRects(attachPoint.x, attachPoint.y);
			paint();
		}

		public function getSize(): Point
		{
			return size;
		}

		public function getRectangle(): Rectangle
		{
			return rect;
		}
		
		public function getAttachRectangle(): Rectangle
		{
			return attachRect;
		}
		
		public function getMinimumSize(): Point
		{
			return minSize;
		}

		public function getInteractiveRectangle(): Rectangle
		{
			return rect;
		}
		
		public function getResizeRectangle0(): Rectangle
		{
			return resizeRect0;
		}
		
		public function getResizeRectangle1(): Rectangle
		{
			return resizeRect1;
		}
		
		public function getResizeRectangle2(): Rectangle
		{
			return resizeRect2;
		}
		
		public function getResizeRectangle3(): Rectangle
		{
			return resizeRect3;
		}
		
		public function getCloseRectangle(): Rectangle
		{
			return closeRect;
		}

		protected function paint(): void
		{
		  var pts: Array = new Array;
		  var p0:Point = new Point;
			var p1:Point = new Point;
			var p2:Point = new Point;
			var p3:Point = new Point;
			var angle0:Number;
			var angle1:Number;
		  
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x666666);
			
			if(attachPoint.y < rect.top) {
			   if(attachPoint.x < rect.left) {
			      pts.push(new Point(rect.left, rect.top+ATTACH_LENGTH/2));
			      pts.push(attachPoint);
			      pts.push(new Point(rect.left+ATTACH_LENGTH/2, rect.top));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			   } else if(attachPoint.x > rect.right) {
			      pts.push(new Point(rect.right, rect.top+ATTACH_LENGTH/2));
			      pts.push(attachPoint);
			      pts.push(new Point(rect.right-ATTACH_LENGTH/2, rect.top));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			   } else {
			      
            p0 = new Point(centerPoint.x, centerPoint.y);
			      p1 = new Point(attachPoint.x, attachPoint.y);
			      p2 = new Point(rect.left, rect.top);
			      p3 = new Point(rect.right, rect.top);
			      
			      //Alert.show(centerPoint.x.toString()+ " c " + centerPoint.y.toString());
			      
			      angle0 = _math.GetAngle(p1, p0);
				    angle1 = _math.GetAngle(p3, p2);
			      point = _math.GetCrossPoint( p0, angle0, p2, angle1 );
			      
			      //Alert.show(point.x.toString()+ " " + point.y.toString());
			      
			      if(point.x - rect.left < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top)); 
			         pts.push(attachPoint);
			         pts.push(new Point(rect.left+ATTACH_LENGTH+RESIZE_RECT_WIDTH, rect.top));
			      } else if(rect.right - point.x < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.right-ATTACH_LENGTH-RESIZE_RECT_WIDTH, rect.top));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      } else {
			         pts.push(new Point(point.x-ATTACH_LENGTH/2, rect.top));
			         pts.push(attachPoint);
			         pts.push(new Point(point.x+ATTACH_LENGTH/2, rect.top));
			         
			      }
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			   }
			} else if(attachPoint.y > rect.bottom) {
			   if(attachPoint.x < rect.left) {
			      pts.push(new Point(rect.left, rect.bottom-ATTACH_LENGTH/2));
			      pts.push(attachPoint);
			      pts.push(new Point(rect.left+ATTACH_LENGTH/2, rect.bottom));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			   } else if(attachPoint.x > rect.right) {
			      pts.push(new Point(rect.right, rect.bottom-ATTACH_LENGTH/2));
			      pts.push(attachPoint);
			      pts.push(new Point(rect.right-ATTACH_LENGTH/2, rect.bottom));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			   } else {
            p0 = new Point(centerPoint.x, centerPoint.y);
			      p1 = new Point(attachPoint.x, attachPoint.y);
			      p2 = new Point(rect.left, rect.bottom);
			      p3 = new Point(rect.right, rect.bottom);
			      
			      //Alert.show(centerPoint.x.toString()+ " c " + centerPoint.y.toString());
			      
			      angle0 = _math.GetAngle(p1, p0);
				    angle1 = _math.GetAngle(p3, p2);
			      point = _math.GetCrossPoint( p0, angle0, p2, angle1 );
			      
			      //Alert.show(point.x.toString()+ " " + point.y.toString());
			      
			      if(point.x - rect.left < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom)); 
			         pts.push(attachPoint);
			         pts.push(new Point(rect.left+ATTACH_LENGTH+RESIZE_RECT_WIDTH, rect.bottom));
			      } else if(rect.right - point.x < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.right-ATTACH_LENGTH-RESIZE_RECT_WIDTH, rect.bottom));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      } else {
			         pts.push(new Point(point.x-ATTACH_LENGTH/2, rect.bottom));
			         pts.push(attachPoint);
			         pts.push(new Point(point.x+ATTACH_LENGTH/2, rect.bottom));
			         
			      }
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			   }
			} else {
			   if(attachPoint.x < rect.left) {
			      p0 = new Point(centerPoint.x, centerPoint.y);
			      p1 = new Point(attachPoint.x, attachPoint.y);
			      p2 = new Point(rect.left, rect.top);
			      p3 = new Point(rect.left, rect.bottom);
			      
			      //Alert.show(centerPoint.x.toString()+ " c " + centerPoint.y.toString());
			      
			      angle0 = _math.GetAngle(p1, p0);
				    angle1 = _math.GetAngle(p3, p2);
			      point = _math.GetCrossPoint( p0, angle0, p2, angle1 );
			      
			      //Alert.show(point.x.toString()+ " " + point.y.toString());
			      
			      if(point.y - rect.top < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH)); 
			         pts.push(attachPoint);
			         pts.push(new Point(rect.left, rect.top+ATTACH_LENGTH+RESIZE_RECT_WIDTH));
			      } else if(rect.bottom - point.y < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.left, rect.bottom-ATTACH_LENGTH-RESIZE_RECT_WIDTH));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      } else {
			         pts.push(new Point(rect.left, point.y-ATTACH_LENGTH/2));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.left, point.y+ATTACH_LENGTH/2));
			         
			      }
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			   } else if(attachPoint.x > rect.right) {
			      p0 = new Point(centerPoint.x, centerPoint.y);
			      p1 = new Point(attachPoint.x, attachPoint.y);
			      p2 = new Point(rect.right, rect.top);
			      p3 = new Point(rect.right, rect.bottom);
			      
			      //Alert.show(centerPoint.x.toString()+ " c " + centerPoint.y.toString());
			      
			      angle0 = _math.GetAngle(p1, p0);
				    angle1 = _math.GetAngle(p3, p2);
			      point = _math.GetCrossPoint( p0, angle0, p2, angle1 );
			      
			      //Alert.show(point.x.toString()+ " " + point.y.toString());
			      
			      if(point.y - rect.top < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH)); 
			         pts.push(attachPoint);
			         pts.push(new Point(rect.right, rect.top+ATTACH_LENGTH+RESIZE_RECT_WIDTH));
			      } else if(rect.bottom - point.y < ATTACH_LENGTH/2+RESIZE_RECT_WIDTH) {
			         pts.push(new Point(rect.right, rect.bottom-ATTACH_LENGTH-RESIZE_RECT_WIDTH));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      } else {
			         pts.push(new Point(rect.right, point.y-ATTACH_LENGTH/2));
			         pts.push(attachPoint);
			         pts.push(new Point(rect.right, point.y+ATTACH_LENGTH/2));      
			      }
			      pts.push(new Point(rect.right, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.bottom));
			      pts.push(new Point(rect.left, rect.bottom-RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left, rect.top+RESIZE_RECT_WIDTH));
			      pts.push(new Point(rect.left+RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right-RESIZE_RECT_WIDTH, rect.top));
			      pts.push(new Point(rect.right, rect.top+RESIZE_RECT_WIDTH));
			   } else {
              // This should not happen
              Alert.show("Error happen!");
			   }
			}
			
		  this.graphics.beginFill(bkColor, 1.0);
		  var i: int = pts.length - 1;
		  this.graphics.moveTo(pts[i].x-this.x, pts[i].y-this.y);
		  for( i--; i >= 0; i-- )
			{
				this.graphics.lineTo(pts[i].x-this.x, pts[i].y-this.y);	
			}
			this.graphics.lineTo(pts[pts.length - 1].x-this.x, pts[pts.length - 1].y-this.y);
      this.graphics.endFill();
      
      // update text field position and size
      field.x = _txtFieldXY.x;
      field.y = _txtFieldXY.y;
      field.width = _txtW;
      field.height = _txtH;
      
      // paint small interactive rects
      // Alert.show(resizeSpr0.x.toString()+ "-" + resizeSpr0.y.toString());
      resizeSpr0.graphics.beginFill(0xffffff, 0.0);
      resizeSpr0.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH, RESIZE_RECT_WIDTH);
      resizeSpr0.graphics.endFill();
      
      resizeSpr1.graphics.beginFill(0xffffff, 0.0);
      resizeSpr1.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH, RESIZE_RECT_WIDTH);
      resizeSpr1.graphics.endFill();
      
      resizeSpr2.graphics.beginFill(0xffffff, 0.0);
      resizeSpr2.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH, RESIZE_RECT_WIDTH);
      resizeSpr2.graphics.endFill();
      
      resizeSpr3.graphics.beginFill(0xffffff, 0.0);
      resizeSpr3.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH, RESIZE_RECT_WIDTH);
      resizeSpr3.graphics.endFill();
      
      attachSpr.graphics.beginFill(0xffffff, 0.0);
      attachSpr.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH, RESIZE_RECT_WIDTH);
      attachSpr.graphics.endFill();
      
      closeSpr.graphics.beginFill(0xffffff, 1.0);
      closeSpr.graphics.drawRect(0, 0, RESIZE_RECT_WIDTH*2, RESIZE_RECT_WIDTH);
      closeSpr.graphics.endFill();
		}
		
		public function onTick( frameTimeSec: Number ): void
		{
		}
		
		public function onEnterFrame( evt: Event ): void
		{
			onRender();
		}
		
		public function onRender(): void
		{
		}

		public function onBeforeBitmapCopy(): void
		{
		}
		
		public function onAfterBitmapCopy(): void
		{
		}

		public function onMouseUp( evt: MouseEvent ): void
		{
		}

		public function onMouseDown( evt: MouseEvent ): void
		{
		}

		public function onMouseMove( evt: MouseEvent ): void
		{
		}


		private function setPositionCoords( anX: Number, anY: Number ): void
		{
			this.x = anX;
			this.y = anY;

			updateRects(attachPoint.x, attachPoint.y);
		}

		public function translate( anOffset: Point ): void
		{
			this.x += anOffset.x;
			this.y += anOffset.y;
			attachPoint.x += anOffset.x;
			attachPoint.y += anOffset.y;
			
			updateRects(attachPoint.x, attachPoint.y);
		}

		protected function updateRects(ax: int, ay:int): void
		{
			rect.x = this.x;
			rect.y = this.y;
			rect.width = size.x;
			rect.height = size.y;
			centerPoint.x = rect.x + rect.width /2;
			centerPoint.y = rect.y + rect.height/2;
			
			attachPoint.x = ax;
			attachPoint.y = ay; 

			resizeRect0.x = rect.left;
			resizeRect0.y = rect.top;
			resizeSpr0.x = resizeRect0.x-rect.x;
			resizeSpr0.y = resizeRect0.y-rect.y;
			resizeRect0.width = RESIZE_RECT_WIDTH;
			resizeRect0.height = RESIZE_RECT_WIDTH;    
			
			resizeRect1.x = rect.right - RESIZE_RECT_WIDTH;
			resizeRect1.y = rect.top;
			resizeSpr1.x = resizeRect1.x-rect.x;
			resizeSpr1.y = resizeRect1.y-rect.y;
			resizeRect1.width = RESIZE_RECT_WIDTH;
			resizeRect1.height = RESIZE_RECT_WIDTH; 
			
			resizeRect2.x = rect.right - RESIZE_RECT_WIDTH;
			resizeRect2.y = rect.bottom  - RESIZE_RECT_WIDTH;
			resizeSpr2.x = resizeRect2.x-rect.x;
			resizeSpr2.y = resizeRect2.y-rect.y;
			resizeRect2.width = RESIZE_RECT_WIDTH;
			resizeRect2.height = RESIZE_RECT_WIDTH; 
			
			resizeRect3.x = rect.left;
			resizeRect3.y = rect.bottom  - RESIZE_RECT_WIDTH;
			resizeSpr3.x = resizeRect3.x-rect.x;
			resizeSpr3.y = resizeRect3.y-rect.y;
			resizeRect3.width = RESIZE_RECT_WIDTH;
			resizeRect3.height = RESIZE_RECT_WIDTH;  

			closeRect.x = rect.right- 3.5*RESIZE_RECT_WIDTH;
			closeRect.y = rect.top+2;
			closeSpr.x = closeRect.x-rect.x;
			closeSpr.y = closeRect.y-rect.y;
			closeRect.width = RESIZE_RECT_WIDTH*2;
			closeRect.height = RESIZE_RECT_WIDTH;
      
		    attachRect.x = attachPoint.x - ATTACH_RECT_WIDTH/2;
			attachRect.y = attachPoint.y - ATTACH_RECT_WIDTH/2;
			attachSpr.x = attachRect.x - this.x;
			attachSpr.y = attachRect.y - this.y;
			attachRect.width = ATTACH_RECT_WIDTH;
			attachRect.height = ATTACH_RECT_WIDTH; 
			
			// text field
			_txtW = rect.width - 20;
			_txtH = rect.height - 20;
			_txtFieldXY.x = rect.x + 10 - this.x;
			_txtFieldXY.y = rect.y + 10 - this.y;
		}

		public function setPosition( aPosition: Point ): void
		{
			setPositionCoords( aPosition.x, aPosition.y );
		}

		public function setColors( aBkColor: uint, aBorderColor: uint ): void
		{
			bkColor = aBkColor;
			paint();
		}

		public function isResizable(): Boolean
		{
			return resizable;
		}

		public function onMoveStarted(): void
		{
			
		}

		public function onMoved(): void
		{
			
		}

		public function onMoveFinished(): void
		{
			
		}
		
		public function onResizeStarted(): void
		{
			
		}

		public function onResized(): void
		{
			
		}
		
		public function onResizeFinished(): void
		{
			
		}
		
		private function moveOverRect0(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(a0Icon);       
		}
	    
	    private function moveOutRect0(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
			
		private function moveOverRect1(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(a1Icon);       
		}
	    
	    private function moveOutRect1(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
			
		private function moveOverRect2(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(a2Icon);       
		}
	    
	    private function moveOutRect2(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
			
		private function moveOverRect3(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(a3Icon);       
		}
	    
	    private function moveOutRect3(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
			
		private function moveOverAtpr(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(atpIcon);       
		}
	    
	    private function moveOutAtpr(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
		
		private function moveOverCloseSpr(evt: MouseEvent):void {
			cursorID = CursorManager.setCursor(closeIcon);       
		}
	    
	    private function moveOutCloseSpr(evt: MouseEvent):void {
			CursorManager.removeCursor(cursorID); 
		}
		
	}
}

