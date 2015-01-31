package
{
	///////////////////////////////////////////////////////////////////////////////////////////
	// DNA Dream
	// Evolution game for Ludum Dare
	// Author: Carlos Peris
	// Date: 27/08/2012
	///////////////////////////////////////////////////////////////////////////////////////////
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.sensors.Accelerometer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF(width=1024, height=768, backgroundColor='0x40A0F0', frameRate='50', allowScriptAccess='always', allowfullscreen='true')]
	public class DNADreamMobile extends Sprite
	{
		public const BASE_Y:int = 700 -20;
		public const BASE_X:int = 800/2;
		
		public const GROW_GAP:int = 80;
		public const SIDE_GAP:int = 80;
		public const LEAF_GAP:int = 30;
		public const LEAF_PERCENT:Number = 0.7;
		
		public const GEN_LOCKED:int = 0;
		public const GEN_UNLOCKED:int = 1;
		
		public const DNA_NONE:int = -1;
		public const DNA_GROW_STRAIGHT:int = 1;
		public const DNA_GROW_RIGHT:int = 0;
		public const DNA_GROW_LEFT:int = 2;
		
		public const START_TIME:int = 30*1000;
		
		private var percent:Number = 0;
		
		private var points:Array = new Array();
		private var pointAtPercent:Point;
		private var dnaLength:int = 0;
		
		private var dna:Array = [DNA_NONE,DNA_NONE,DNA_NONE,DNA_NONE,DNA_NONE,DNA_NONE,DNA_NONE,DNA_NONE];
		private var gens:Array = [GEN_UNLOCKED ,GEN_UNLOCKED,GEN_UNLOCKED];//,GEN_LOCKED,GEN_LOCKED,GEN_LOCKED,GEN_LOCKED,GEN_LOCKED];
		
		private var growSide:int = 1;
		
		private var mDate:Date = new Date();
		
		[Embed(source="data/dna.png")]
		private static const gfxBackground:Class;
		
		[Embed(source="data/gen_empty.png")]
		private static const gfxGenEmpty:Class;
		
		[Embed(source="data/gen_blue.png")]
		private static const gfxGenStraight:Class;
		
		[Embed(source="data/gen_green.png")]
		private static const gfxGenRight:Class;
		
		[Embed(source="data/gen_red.png")]
		private static const gfxGenLeft:Class;
		
		[Embed(source="data/sun.png")]
		private static const gfxItem:Class;
		
		[Embed(source="data/leafRight.png")]
		private static const gfxLeafRight:Class;
		
		[Embed(source="data/leafLeft.png")]
		private static const gfxLeafLeft:Class;
		
		[Embed(source="data/flowerRight.png")]
		private static const gfxFlowerRight:Class;
		
		[Embed(source="data/flowerLeft.png")]
		private static const gfxFlowerLeft:Class;
		
		
		private var leafRight:Bitmap;
		private var leafLeft:Bitmap;
		private var flowerRight:Bitmap;
		private var flowerLeft:Bitmap;
		
		private var leaves:Sprite = new Sprite();
		
		private var hud:Sprite = new Sprite();
		private var dnaSprite:Sprite = new Sprite();
		
		private var hudOpened:Boolean = false;
		private var nodeSelected:int = 0;
		
		
		private var item:Item = new Item;
		
		private var score:int = 0;
		private var topScore:int = 0;
		
		private var mGameTime:Number;
		private var mGameTimeLeft:Number;
		
		private var mTimeLeftTextfield:TextField = new TextField();
		private var mScoreTextfield:TextField = new TextField();
		private var mTopScoreTextfield:TextField = new TextField();
		
		
		public function DNADreamMobile()
		{
			var back:Bitmap = new gfxBackground as Bitmap;
			stage.addChildAt(back, 0);
			
			points = new Array();
			dnaLength = 0;
			setPoint(0, BASE_X, BASE_Y, 0, 0);
			
			init();
			addChild(leaves);
			stage.addChildAt(hud, 1);
			stage.addChild(dnaSprite);
			
			
			
			setPoint(1, BASE_X + growSide*10, BASE_Y - dnaLength * (GROW_GAP/3), growSide*20, -50);
			
			refreshDNA();
			
			mGameTime = currentTimeMillis();
			mGameTimeLeft = START_TIME;
			
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 22;

			myFormat.align = TextFormatAlign.LEFT;					
			
			mTimeLeftTextfield.defaultTextFormat = myFormat;				
			mTimeLeftTextfield.x = 16;
			mTimeLeftTextfield.y = 12;
			mTimeLeftTextfield.textColor = 0xffffff;
			mTimeLeftTextfield.width = 40;

			mTopScoreTextfield.textColor = 0xffffff;
			mTopScoreTextfield.defaultTextFormat = myFormat;	
			mTopScoreTextfield.x = 16;
			mTopScoreTextfield.y = 12+20;
			mTopScoreTextfield.width = 430;
			
			
			mScoreTextfield.textColor = 0xffffff;
			mScoreTextfield.defaultTextFormat = myFormat;	
			mScoreTextfield.x = 16;
			mScoreTextfield.y = 12+20+20;
			mScoreTextfield.width = 430;
			
			stage.addChild(mTimeLeftTextfield);
			stage.addChild(mTopScoreTextfield);
			stage.addChild(mScoreTextfield);
			
			leafLeft = new gfxLeafLeft as Bitmap;
			leafRight = new gfxLeafRight as Bitmap;
			flowerRight = new gfxFlowerRight as Bitmap;
			flowerLeft = new gfxFlowerLeft as Bitmap;
		}
		
		
		
		public function resetGame():void
		{
			
			
			points = new Array();
			dnaLength = 0;
			score = 0;
			mGameTimeLeft = START_TIME;
			setPoint(0, BASE_X, BASE_Y, 0, 0);
			setPoint(1, BASE_X + growSide*10, BASE_Y - dnaLength * (GROW_GAP/3), growSide*20, -50);
			for(var i:int = 0; i < dna.length; i++)
			{
				dna[i] = DNA_NONE;
			}
			closeHUD();
			refreshDNA();
			regenerate();
			
			var randX:int = 4;
			var randY:int = 1;
			item.x = (BASE_X - (SIDE_GAP*4) + (randX)*SIDE_GAP) - 16;
			item.y = BASE_Y - GROW_GAP - GROW_GAP - GROW_GAP -(randY)*GROW_GAP;			
		}
		
		
		private var a:Number = 0;
		
		public function updateDNA():void
		{				
			for (var i:int = 0; i < dna.length; i++)
			{
				var s:Sprite = dnaSprite.getChildAt(i) as Sprite;
				s.getChildAt(0).x = 860+(Math.sin(a + (i*0.6)) * 60);
				s.getChildAt(1).x = 860-(Math.sin(a + (i*0.6)) * 60);
				
				s.getChildAt(0).z = Math.cos((a + (i*0.6)))*15;
				s.getChildAt(1).z = Math.cos((a + (i*0.6))+Math.PI)*15;
								
				
				if (s.getChildAt(1).z > s.getChildAt(0).z)
				{
					s.swapChildren(s.getChildAt(1), s.getChildAt(0));
				}
			}
			a+= 0.025;
		}
		
		
		public function refreshDNA():void
		{				
			dnaSprite.removeChildren();
			
			var b:Bitmap;
			for (var i:int = 0; i < dna.length; i++)
			{
				switch(dna[i])
				{
					case 0:
						b = new gfxGenStraight as Bitmap;
						break;
					case 1:
						b = new gfxGenRight as Bitmap;
						break;
					case 2:
						b = new gfxGenLeft as Bitmap;
						break;
					default:
						b = new gfxGenEmpty as Bitmap;
						break;
				}
				
				var c:Bitmap = new Bitmap(b.bitmapData);
				
				b.x = 900;
				b.y = BASE_Y - i*GROW_GAP - 80;
				
				
				c.x = 900;
				c.y = BASE_Y - i*GROW_GAP - 80;
				
				
				var s:Sprite = new Sprite();
				if (i >= dnaLength - 1)
				{
					b.alpha = 0.3;
					c.alpha = 0.3;
				}
				s.addChild(b);
				s.addChild(c);
				
				dnaSprite.addChild(s);
				s.name = ""+i;
				s.addEventListener(MouseEvent.CLICK, onClickDNA);
				
			}
			
		}
		
		
		
		public function refreshHUD(node:int=0):void
		{		
			stage.setChildIndex(hud, stage.numChildren-1);
			hud.removeChildren();
			for (var i:int = 0; i < gens.length; i++)
			{
				var b:Bitmap;
				if (gens[i] == GEN_UNLOCKED)
				{
					switch(i)
					{
						case 0:
							b = new gfxGenStraight as Bitmap;
							break;
						case 1:
							b = new gfxGenRight as Bitmap;
							break;
						case 2:
							b = new gfxGenLeft as Bitmap;
							break;					
					}
				}
				else
				{
					b = new gfxGenEmpty as Bitmap;
					b.alpha = 0.4;
				}
				b.x = 740-(i*70);
				b.y = BASE_Y - node*85 - 80;
				var s:Sprite = new Sprite();
				s.addChild(b);
				s.name = ""+i;
				s.addEventListener(MouseEvent.CLICK, onClickGen);
				hud.addChild(s);		
			}
			
		}
		
		
		public function setPoint(pos:int, x1:int, y1:int ,x2:int ,y2:int):void
		{
			//points.push(new Point(x1, y1));
			//points.push(new Point(x2, y2));
			var p1:Point = points[pos*2] as Point;
			var p2:Point = points[(pos*2) + 1] as Point;
			if (!p1)
			{
				p1 = new Point(x1, y1);
				p2 = new Point(x2, y2);
				if (dnaLength <= dna.length+1)
				{
					dnaLength++;	
				}
				trace("new point " + pos);
			}
			else
			{
				p1.x = x1;			
				p1.y = y1;
				p2.x = x2;
				p2.y = y2;
				trace("old point " + pos);
			}
			points[pos*2] = p1;
			points[(pos*2) + 1] = p2;
		}
		
		
		
		
		private function init():void
		{
			stage.doubleClickEnabled = true;
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, reset);
			//stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			reset();
			
			createSun();
			
			
			this.addEventListener(Event.ENTER_FRAME, logicUpdate);
		}
		
		
		private function createSun():void
		{
			var b:Bitmap = new gfxItem as Bitmap;
			b.scaleX = 0.25;
			b.scaleY = 0.25;
			item.addChild(b);
			stage.addChild(item);
			
			var randX:int = 4;
			var randY:int = 1;
			item.x = (BASE_X - (SIDE_GAP*4) + (randX)*SIDE_GAP) - 16;
			item.y = BASE_Y - GROW_GAP - GROW_GAP - GROW_GAP -(randY)*GROW_GAP;
			
			var aura:Sprite = new Sprite();
			var mat:Matrix;
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			mat= new Matrix();
			colors=[0xFFFF00, 0xff8f00];
			alphas=[0.5,0.025];
			ratios=[0, 255];		
			mat.createGradientBox(200,200,0,-100,-100);
			aura.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, mat);       
			aura.graphics.drawCircle(0,0, 100);
			aura.graphics.endFill();
			aura.x = 16;
			aura.y = 16;
			item.addChild(aura);

		}
		
		
		private function randItem():void
		{
			var randX:int = Math.random()*8;
			var randY:int = Math.random()*5;
			trace("randX "+randX);
			trace("randY "+randY);
			item.x = (BASE_X - (SIDE_GAP*4) + (randX)*SIDE_GAP) - 16;
			item.y = BASE_Y - GROW_GAP - GROW_GAP - GROW_GAP - GROW_GAP -(randY)*GROW_GAP;
		}
		
		
		private function onMouseClick(event:MouseEvent = null) : void 
		{
			//addPoint(BASE_X, BASE_Y - dnaLength * 95, 0, 0);
		}
		
		private function onClickDNA(event:MouseEvent = null) : void 
		{
			if (hudOpened)
			{
				closeHUD();
			}
			else
			{				
				var s:Sprite = event.target as Sprite;
				nodeSelected = int(s.name);
				if (nodeSelected <= dnaLength - 2)
				{
					hudOpened = true;				
					refreshHUD(nodeSelected);
					hud.visible = true;
				}
			}
			
			//addPoint(BASE_X, BASE_Y - dnaLength * 95, 0, 0);
		}
		
		
		
		private function onClickGen(event:MouseEvent = null) : void 
		{
			var s:Sprite = event.target as Sprite;
			var genSelected:int = int(s.name);
			if (gens[genSelected] == GEN_UNLOCKED)
			{
				if (dna[nodeSelected] == DNA_NONE)
				{
					growSide = nodeSelected % 2 == 0? -1:1;  
					
				}
				trace("node" + nodeSelected);
				var oldBase:Point = points[((nodeSelected+1)*2)];
				var oldBaseX:Number = oldBase.x;
				var oldBaseY:Number = oldBase.y;
				switch(genSelected)
				{
					case DNA_GROW_STRAIGHT:									
						setPoint((nodeSelected+2), oldBaseX + growSide*10, BASE_Y - (nodeSelected+1) * GROW_GAP, growSide*20, -50);
						break;
					case DNA_GROW_RIGHT:	
						setPoint((nodeSelected+2), oldBaseX + SIDE_GAP, BASE_Y - (nodeSelected+1) * GROW_GAP, growSide*20, -50);
						break;
					case DNA_GROW_LEFT:	
						setPoint((nodeSelected+2), oldBaseX - SIDE_GAP, BASE_Y - (nodeSelected+1) * GROW_GAP, growSide*20, -50);
						break;
				}
				
				dna[nodeSelected] = genSelected;
				regenerate();
				
				//dna[nodeSelected] = genSelected;
				refreshDNA();
			}
			closeHUD();
			
		}
		
		
		public function regenerate():void
		{
			for(var i:int = 0; i < dnaLength-1; i++)
			{
				
				var currentNode:int = i;
				var genSelected:int = dna[i];
				growSide = currentNode % 2 == 0? -1:1;  
				var oldBase:Point = points[((currentNode+1)*2)];
				var oldBaseX:Number = oldBase.x;
				var oldBaseY:Number = oldBase.y;
				switch(genSelected)
				{
					case DNA_GROW_STRAIGHT:									
						setPoint((currentNode+2), oldBaseX + growSide*10, BASE_Y - (currentNode+1) * GROW_GAP, growSide*20, -50);
						break;
					case DNA_GROW_RIGHT:	
						setPoint((currentNode+2), oldBaseX + SIDE_GAP, BASE_Y - (currentNode+1) * GROW_GAP, growSide*20, -50);
						break;
					case DNA_GROW_LEFT:	
						setPoint((currentNode+2), oldBaseX - SIDE_GAP, BASE_Y - (currentNode+1) * GROW_GAP, growSide*20, -50);
						break;
				}
			}
			reset();
		}
		
		
		public function closeHUD():void
		{
			hud.visible = false;
			hudOpened = false;
		}
		
		
		private function reset(event:MouseEvent = null):void 
		{
			prevY = 700;
			leaves.removeChildren();
			graphics.clear();
			percent = 0;			
		}
		
		
		private var prevY:int = 700;
		
		
		private function logicUpdate(event:Event):void 
		{	
			if (mGameTimeLeft <= 0)
			{
				resetGame();
			}
			
			updateDNA();
			
			
			var timeMillis:Number = currentTimeMillis();
			var dt:int = timeMillis - mGameTime;
			mGameTime = timeMillis;
			if (score > 0)
			{
				mGameTimeLeft -= dt;
				topScore = Math.max(topScore, score);
			}

			item.scaleX = 1.08 + (Math.sin(timeMillis/200)*0.08);
			item.scaleY = 1.08 + (Math.sin(timeMillis/200)*0.08);
			
			
			mTimeLeftTextfield.text = ""+Math.floor(mGameTimeLeft / 1000);
			mTimeLeftTextfield.x = item.x+5;
			mTimeLeftTextfield.y = item.y-24;
			mScoreTextfield.text = "Score: "+score;
			mTopScoreTextfield.text = "Top Score: "+topScore;
			
			var i:int = 0;
			while(i < dnaLength - percent)
			{
				if (percent >= dnaLength-1) return;
				if (dnaLength < 1) return;
				
				pointAtPercent = hermite(percent, points);
				
				if(percent == 0)
				{
					graphics.moveTo(pointAtPercent.x, pointAtPercent.y);
				}
				
				
				graphics.lineStyle((4*dnaLength) - (percent*4), 0x009900 + 0x000600*Math.floor(percent));
				//graphics.lineGradientStyle(GradientType.RADIAL, [0x0000FF, 0xFF0000], [1, 1], [0, 255]);
				
				graphics.lineTo(pointAtPercent.x, pointAtPercent.y);
				
				if (prevY > pointAtPercent.y && pointAtPercent.y < 650)
				{
					var b:Bitmap;
					if (Math.random() > LEAF_PERCENT)
					{
						b = new Bitmap(leafRight.bitmapData);
						leaves.addChild(b);
						b.x = pointAtPercent.x;
						b.y = pointAtPercent.y - 25;												
					}
					if (Math.random() > LEAF_PERCENT)
					{
						b = new Bitmap(leafLeft.bitmapData);
						leaves.addChild(b);
						b.x = pointAtPercent.x - leafLeft.width;
						b.y = pointAtPercent.y - 25;												
					}
					
					if (Math.random() > 0.8)
					{
						if (growSide > 0)
						{
							b = new Bitmap(flowerRight.bitmapData);
							b.x = pointAtPercent.x - growSide * 11;
							
						}
						else
						{
							b = new Bitmap(flowerLeft.bitmapData);
							b.x = pointAtPercent.x - flowerLeft.width - growSide * 11;		
							score += 5;
						}
						leaves.addChild(b);
						b.y = pointAtPercent.y -45;
					}
					
					prevY = pointAtPercent.y - LEAF_GAP - Math.random()*LEAF_GAP;
				}				
				//graphics.moveTo(pointAtPercent.x, pointAtPercent.y);
				
				percent += .020;
				i++;
				
				
				if (Math.abs(pointAtPercent.x - item.x) < 30 && Math.abs(pointAtPercent.y - item.y) < 30)
				{
					randItem();
					regenerate();
					if (score > 2000)
					{
						mGameTimeLeft += 8*1000;
					}
					if (score > 1000)
					{
						mGameTimeLeft += 10*1000;
					}
					mGameTimeLeft += 15*1000;
					score += 100;
				}
			}
			
		}
		
				
		private function hermite(t:Number, points:Array):Point
		{
			var i:int = 0;
			i = Math.floor(t) * 2;
			t = t - Math.floor(t);
					
			var p:Point = new Point();
			
			p.x = (2 * Math.pow(t, 3) - 3 * t * t + 1) * points[i].x +
				(Math.pow(t, 3) - 2 * t * t + t) * points[i+1].x + 
				(- 2 * Math.pow(t,3) + 3*t*t) * points[i+2].x +
				( Math.pow(t, 3) - t*t) * points[i+3].x;
			
			p.y = (2 * Math.pow(t,3) - 3 * t * t + 1) * points[i].y+
				(Math.pow(t, 3) - 2 * t * t + t) * points[i+1].y + 
				(- 2 * Math.pow(t, 3) + 3*t*t) * points[i+2].y +
				( Math.pow(t, 3) - t*t) * points[i+3].y;
			
			return p;
		}
		
		
		public function currentTimeMillis():Number
		{
			mDate = new Date();
			return mDate.getTime();
		}

	}
}