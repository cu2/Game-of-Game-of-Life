package {
	import org.flixel.*;
	public class PlayState extends FlxState {
		public var ca:Array;
		public var caIndex:uint = 0;
		public var caAuxSum:uint = 0;
		public var caNumberOfLivingCells:uint = 0;
		private var timeToNextTick:Number = 0;
		protected static const CA_SPEED:Number = 0.1;
		private var x1:Number;
		private var x2:Number;
		private var y1:Number;
		private var y2:Number;
		//
		public var player:FlxSprite;
		protected static const PLAYER_MAX_SPEED:Number = 200;
		private var player_speed:Number = 0;
		private var player_dir:Number = 0;
		private var player_shield:Number = 100;
		private var player_hp:Number = 100;
		private var player_time:Number = 0;
		private var player_shielded:uint = 0;
		//
		public var textTitle:FlxText;
		public var textIntro:FlxText;
		public var textCopyright:FlxText;
		public var textHappyEnd:FlxText;
		public var textBadEnd:FlxText;
		public var hudHP:FlxText;
		public var hudShield:FlxText;
		public var hudTime:FlxText;
		//
		public var gamePhase:uint = 0;
		//
    	[Embed(source="data/ca_map.png")] public static var CAMapPng:Class;
    	[Embed(source="data/tileset.png")] public static var TileSet:Class;
		[Embed(source="data/player.png")] public static var PlayerSprite:Class;
		[Embed(source="data/background.jpg")] public static var BackGroundImage:Class;
		[Embed(source="data/verdana.ttf",fontName="verdana")] private var FontClass:Class;
    	[Embed(source="data/backgroundmusic.mp3")] public static var BackgroundMusic:Class;
		//
		override public function create():void {
			FlxG.playMusic(BackgroundMusic,1);
			bgColor = 0xffaaaaaa;
			var backg:FlxSprite;
			backg = new FlxSprite(0,0,BackGroundImage);
			add(backg);
			
			//ca
			ca = new Array();
			ca.push(new FlxTilemap());
			ca.push(new FlxTilemap());
			ca[0].loadMap(FlxTilemap.pngToCSV(CAMapPng),TileSet);
			ca[1].loadMap(FlxTilemap.pngToCSV(CAMapPng),TileSet);
			caNumberOfLivingCells=0;
			for (var y:Number=0; y<ca[0].heightInTiles ; y++) for (var x:Number=0; x<ca[0].widthInTiles ; x++) {
				ca[0].setTile(x,y,Math.floor(2*Math.random()));
				caNumberOfLivingCells+=ca[0].getTile(x,y);
			}
			ca[0].exists=true;
			ca[1].exists=false;
			add(ca[0]);
			add(ca[1]);
			timeToNextTick=CA_SPEED;
			
			//player
			player = new FlxSprite(FlxG.width/2-25,FlxG.height-100);
			player.loadGraphic(PlayerSprite, true, false, 50, 50);
			for(var j:uint=0;j<36;j++) player.addAnimation('go_'+j,[j]);
			for(var i:uint=0;i<36;i++) player.addAnimation('shield_'+i,[i+36,i+2*36,i+3*36,i+4*36],20);
			player_dir=0;
			player.play('go_'+Math.round(player_dir/10));
			add(player);
			
			//hud texts
			textTitle = new FlxText(0,FlxG.height/5-50,FlxG.width,"Game of Game of Life");
			textTitle.setFormat('verdana',36,0xffffffff,'center',0xff000000);
			textIntro = new FlxText(0.1*FlxG.width,FlxG.height/4,0.8*FlxG.width,"Red pixels follow the rules of Conway's Game of Life. If your spaceship touches them, it loses HP. Except when its shield is active, in which case the pixels touched are destroyed. Your goal is the annihilate all the pixels as fast as possible.\n\nIn the upper left corner is the HP of your ship, on the top in the middle is your shield (it loads continuously), in the upper right corner is the time elapsed. Control: speed up ship - UP key, slow down ship - DOWN key, steer ship - LEFT/RIGHT keys, activate shield - SPACE key.\n\nPress UP if you're ready.");
			textIntro.setFormat('verdana',16,0xffffffff,'center',0xff000000);
			textCopyright = new FlxText(0,FlxG.height-19,FlxG.width-1,"Created by Zanda Games");
			textCopyright.setFormat(null,12,0xffffffff,'right',0xff000000);
			textHappyEnd = new FlxText(0,FlxG.height/2-20,FlxG.width,"You have won in X seconds!");
			textHappyEnd.setFormat('verdana',36,0xffffffff,'center',0xff000000);
			textBadEnd = new FlxText(0,FlxG.height/2-20,FlxG.width,"You are dead!");
			textBadEnd.setFormat('verdana',36,0xffffffff,'center',0xff000000);
			textHappyEnd.exists=false;
			textBadEnd.exists=false;
			//
			add(textTitle);
			add(textIntro);
			add(textCopyright);
			add(textHappyEnd);
			add(textBadEnd);
			
			//hud
			hudHP = new FlxText(2,2,80,"HP "+Math.ceil(player_hp));
			hudHP.setFormat(null,12,0xffffffff,'left',0xff000000);
			add(hudHP);
			hudShield = new FlxText(FlxG.width/2-40,2,80,"SHIELD "+Math.ceil(player_shield));
			hudShield.setFormat(null,12,0xffffffff,'center',0xff000000);
			add(hudShield);
			hudTime = new FlxText(FlxG.width-80,2,80,Math.floor(player_time)+" s");
			hudTime.setFormat(null,12,0xffffffff,'right',0xff000000);
			add(hudTime);
		}
		override public function update():void {
			//ca
			if (gamePhase>0) {
				timeToNextTick-=FlxG.elapsed;
				if (timeToNextTick<0) {
					timeToNextTick=CA_SPEED;
					caNumberOfLivingCells=0;
					for (var y:Number=0; y<ca[0].heightInTiles ; y++) {
						for (var x:Number=0; x<ca[0].widthInTiles ; x++) {
							if (ca[caIndex].getTile(x,y)) caNumberOfLivingCells++;
							caAuxSum=0;
							if (y>0) y1=y-1;else y1=ca[0].heightInTiles-1;
							if (x>0) x1=x-1;else x1=ca[0].widthInTiles-1;
							if (y<ca[0].heightInTiles-1) y2=y+1;else y2=0;
							if (x<ca[0].widthInTiles-1) x2=x+1;else x2=0;
							caAuxSum+=ca[caIndex].getTile(x1,y1);
							caAuxSum+=ca[caIndex].getTile(x ,y1);
							caAuxSum+=ca[caIndex].getTile(x2,y1);
							caAuxSum+=ca[caIndex].getTile(x1,y);
							caAuxSum+=ca[caIndex].getTile(x2,y);
							caAuxSum+=ca[caIndex].getTile(x1,y2);
							caAuxSum+=ca[caIndex].getTile(x ,y2);
							caAuxSum+=ca[caIndex].getTile(x2,y2);
							if (ca[caIndex].getTile(x,y)==1) {
								if (caAuxSum==2 || caAuxSum==3) ca[1-caIndex].setTile(x,y,1);else ca[1-caIndex].setTile(x,y,0);
							} else {
								if (caAuxSum==3) ca[1-caIndex].setTile(x,y,1);else ca[1-caIndex].setTile(x,y,0);
							}
						}
					}
					ca[1-caIndex].exists=true;
					ca[caIndex].exists=false;
					caIndex=1-caIndex;
				}
			}
			
			player_shielded=0;
			//interaction
			if (gamePhase==0) {
				if (FlxG.keys.UP || FlxG.keys.W) {
					gamePhase=1;textIntro.exists=false;textTitle.exists=false;
				}
			} else if (gamePhase==1) {
				player_time+=FlxG.elapsed;
				if (FlxG.keys.UP || FlxG.keys.W) {player_speed+=5;if (player_speed>PLAYER_MAX_SPEED) player_speed=PLAYER_MAX_SPEED;}
				if (FlxG.keys.DOWN || FlxG.keys.S) {player_speed-=5;if (player_speed<0) player_speed=0;}
				if (FlxG.keys.LEFT || FlxG.keys.A) {player_dir-=3;if (player_dir<0) player_dir+=360;}
				if (FlxG.keys.RIGHT || FlxG.keys.D) {player_dir+=3;if (player_dir>359) player_dir-=360;}
				if (FlxG.keys.SPACE) {
					if (player_shield>50*FlxG.elapsed) {
						player_shield-=50*FlxG.elapsed;
						player.play('shield_'+Math.round(player_dir/10));
						player_shielded=1;
						for (var yy:Number=Math.round((player.y+0)/8); yy<=Math.round((player.y+50)/8) ; yy++) {
							for (var xx:Number=Math.round((player.x+0)/8); xx<=Math.round((player.x+50)/8) ; xx++) {
								ca[caIndex].setTile(xx,yy,0);
								ca[1-caIndex].setTile(xx,yy,0);
							}
						}
					} else {
						player.play('go_'+Math.round(player_dir/10));
					}
				} else {
					player.play('go_'+Math.round(player_dir/10));
				}
				player_shield+=10*FlxG.elapsed;if (player_shield>100) player_shield=100;
				player.velocity.x=player_speed*Math.cos((player_dir-90)/180*Math.PI);
				player.velocity.y=player_speed*Math.sin((player_dir-90)/180*Math.PI);
				if (player.x<-25) player.x+=FlxG.width;
				if (player.x>FlxG.width-25) player.x-=FlxG.width;
				if (player.y<-25) player.y+=FlxG.height;
				if (player.y>FlxG.height-25) player.y-=FlxG.height;
				//
				hudHP.text="HP "+Math.ceil(player_hp);
				hudShield.text="SHIELD "+Math.ceil(player_shield);
				hudTime.text=Math.floor(player_time)+" s";
			}
			//
			super.update();
			//
			if (gamePhase==1) if (player_shielded==0) if (ca[caIndex].overlaps(player)) player_hp-=20*FlxG.elapsed;
			if (gamePhase==1) if (player_hp<0) {
				gamePhase=3;textBadEnd.exists=true;
				hudHP.text="HP 0";
				defaultGroup.remove(player,true);
			}
			if (gamePhase==1) if (caNumberOfLivingCells<=0) {
				textHappyEnd.text="You have won in "+Math.floor(player_time)+" second"+((Math.floor(player_time)>1)?"s":"")+"!";
				gamePhase=2;textHappyEnd.exists=true;
				defaultGroup.remove(player,true);
			}
		}
	}
}