package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'play',
		'extra',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	public static var extraLocked:Bool = ClientPrefs.extras;
	var mainsheets:FlxSprite;
	var charchance:Int;
	var char:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		//.changeBPM(102);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		mainsheets = new FlxSprite();
		mainsheets.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/papel');
		mainsheets.animation.addByPrefix('idle', 'papel', 24, true);
		mainsheets.animation.play('idle');
		mainsheets.setPosition(5,0);
		mainsheets.antialiasing = ClientPrefs.globalAntialiasing;
		add(mainsheets);
		
		var cartel:FlxSprite = new FlxSprite();
		cartel.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/cartel');
		cartel.animation.addByPrefix('idle', 'cartel', 24, true);
		cartel.animation.play('idle');
		cartel.setGraphicSize(523,249);
		cartel.updateHitbox();
		cartel.setPosition(775,-20);
		cartel.antialiasing = ClientPrefs.globalAntialiasing;
		add(cartel);

		var letras:FlxSprite = new FlxSprite();
		letras.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/Baldo funk escol');
		letras.animation.addByPrefix('idle', 'BALDO FUNK ESCOL', 24, true);
		letras.animation.play('idle');
		letras.setPosition(830,0);
		letras.antialiasing = ClientPrefs.globalAntialiasing;
		add(letras);

		char = new FlxSprite();
		charchance = FlxG.random.int(0,3);
		switch(charchance)
		{
			case 0:
				char.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/ANGRYBALDO');
				char.animation.addByPrefix('idle', 'ANGRYBALDO', 24, true);
				char.setPosition(580,190);
			case 1:
				char.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/BALDO');
				char.animation.addByPrefix('idle', 'BALDO', 24, true);
				char.setPosition(580,190);
			case 2:
				char.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/BEFE');
				char.animation.addByPrefix('idle', 'BEFE', 24, true);
				char.setPosition(580,350);
			case 3:
				char.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/FILENAME2');
				char.animation.addByPrefix('idle', 'FILENAME2', 24, true);
				char.setPosition(580,250);
		}
		char.animation.play('idle');
		char.x = 600;
		char.antialiasing = ClientPrefs.globalAntialiasing;
		add(char);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1.2;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 120) + offset + 110);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			if(i != 1)
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/${optionShit[i].toUpperCase()}');
			else
				if(extraLocked)
					menuItem.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/${optionShit[i].toUpperCase()} locked');
				else
					menuItem.frames = Paths.getSparrowAtlas('mainmenu/Menu Baldo assets/${optionShit[i].toUpperCase()} normal');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x -= 400;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			switch(i)
			{
				case 0: 
					menuItem.y -= 25;
					menuItem.x -= 70;
				case 1:
					menuItem.y -= 10;
					menuItem.x -= 50;
				case 2:
					menuItem.x += 15;
					menuItem.setGraphicSize(Std.int(menuItem.width * 0.75));
			}
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height + 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height + 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		Conductor.changeBPM(102);

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if(FlxG.keys.pressed.Z)
				extraLocked = false;

			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if(optionShit[curSelected] != 'extra')
				{
					if (optionShit[curSelected] == 'donate')
					{
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
		
						if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
		
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									var daChoice:String = optionShit[curSelected];
	
									switch (daChoice)
									{
										case 'play':
											MusicBeatState.switchState(new StoryMenuState());
										case 'extra':
											MusicBeatState.switchState(new FreeplayState());
										case 'awards':
											MusicBeatState.switchState(new AchievementsMenuState());
										case 'credits':
											MusicBeatState.switchState(new CreditsState());
										case 'options':
											LoadingState.loadAndSwitchState(new options.OptionsState());
									}
								});
							}
						});
					}
				} else
				{
					if(!extraLocked)
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
		
						if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
		
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker){MusicBeatState.switchState(new FreeplayState());});
							}
						});
					}
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x -= 400;
		});*/
		//Conductor.changeBPM(102);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
			spr.offset.x = 0;
			spr.offset.y = 0;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.offset.x = -3;
				switch(spr.ID)
				{
					case 0 | 1:
						spr.offset.y = 13;
					default:
						spr.offset.y = 23;
				}
			}
		});
	}

	override function beatHit()
	{
		super.beatHit();

		//Conductor.changeBPM(102);
		if(curBeat % 2 == 0)
			char.animation.play('idle', true);
	}
}
