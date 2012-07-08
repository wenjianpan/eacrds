package
{   
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import mx.controls.Alert;
	import mx.controls.Image; 
    
    public class MyImage extends Image 
    { 
        public var ht:Sprite = new Sprite(); 
        public function MyImage() 
        { 
            addChild(ht); 
            hitArea = ht; 
             
            ht.visible = false; 
            ht.mouseEnabled = false; 
            mouseChildren = false; 
            addEventListener(Event.COMPLETE,complete,false,99,true); 
            //setTimeout(update,50); 
        } 
        private function complete(e:Event):void
        { 
            //setTimeout(update,50); 
        } 
        public function update(w:int, h:int):void
        { 
            if(this.source == null) return;
            
            var bmp:Bitmap = Bitmap(this.source); 
            var bit:BitmapData = new BitmapData(bmp.bitmapData.width, bmp.bitmapData.height, true, 0x00000000); 
            var mat:Matrix = new Matrix(); 
            mat.scale(w/bmp.bitmapData.width, h/bmp.bitmapData.height); 
            bit.draw(bmp.bitmapData,mat); 
            
            ht.graphics.clear(); 
            ht.graphics.beginFill(0); 
            for(var x:uint=0;x<bit.width;x++) 
            { 
                for(var y:uint=0;y<bit.height;y++) 
                { 
                    if(bit.getPixel32(x,y))ht.graphics.drawRect(x,y,1,1); 
                } 
            } 
             
            ht.graphics.endFill(); 
        } 
    } 
}

