package;

#if mobile
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;
import haxe.io.Path;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.addons.util.FlxAsyncLoop;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CopyState extends MusicBeatState
{
	public static var locatedFiles:Array<String> = [];
	public static var maxLoopTimes:Int = 0;
	public static final IGNORE_FOLDER_FILE_NAME:String = "ignore.txt";

	public var loadingImage:FlxSprite;
	public var bottomBG:FlxSprite;
	public var loadedText:FlxText;
	public var copyLoop:FlxAsyncLoop;

	var loopTimes:Int = 0;
	var failedFiles:Array<String> = [];
	var failedFilesStack:Array<String> = [];
	var canUpdate:Bool = true;
	var shouldCopy:Bool = false;

	// 🔥 LIMITE POR EJECUCIÓN (EVITA REINICIOS)
	var maxPerRun:Int = 50;

	private static final textFilesExtensions:Array<String> = [
		'ini','txt','xml','hxs','hx','lua','json','frag','vert'
	];

	override function create()
	{
		locatedFiles = [];
		maxLoopTimes = 0;

		checkExistingFiles();

		// 🔥 CARGAR PROGRESO GUARDADO
		if (FlxG.save.data.copyProgress != null)
			loopTimes = FlxG.save.data.copyProgress;

		if (maxLoopTimes <= 0)
		{
			FlxG.switchState(new TitleState());
			return;
		}

		SUtil.showPopUp(
			"Missing files detected.\nPress OK to begin copying.",
			"Notice!"
		);

		shouldCopy = true;

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

		loadingImage = new FlxSprite(0, 0, Paths.image('menuBG'));
		loadingImage.setGraphicSize(0, FlxG.height);
		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);

		bottomBG = new FlxSprite(0, FlxG.height - 26)
			.makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		loadedText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
		loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(loadedText);

		var ticks:Int = 5; // 🔥 MÁS ESTABLE

		copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, ticks);
		add(copyLoop);
		copyLoop.start();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (shouldCopy && copyLoop != null)
		{
			// 🔥 GUARDAR PROGRESO CONSTANTEMENTE
			FlxG.save.data.copyProgress = loopTimes;
			FlxG.save.flush();

			if (copyLoop.finished && canUpdate)
			{
				canUpdate = false;

				// 🔥 SOLO TERMINA SI YA COPIÓ TODO
				if (loopTimes >= maxLoopTimes)
				{
					if (failedFiles.length > 0)
					{
						SUtil.showPopUp(
							failedFiles.join('\n'),
							'Failed: ${failedFiles.length} files'
						);
					}

					FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = () ->
					{
						FlxG.switchState(new TitleState());
					};
				}
			}

			loadedText.text = (maxLoopTimes > 0)
				? '$loopTimes/$maxLoopTimes'
				: 'Completed!';
		}

		super.update(elapsed);
	}

	public function copyAsset()
	{
		// 🔥 PROTECCIÓN TOTAL (EVITA CRASH)
		if (loopTimes >= locatedFiles.length || loopTimes >= maxLoopTimes)
			return;

		// 🔥 LIMITE POR EJECUCIÓN (CLAVE)
		if (loopTimes >= maxPerRun)
			return;

		var file = locatedFiles[loopTimes];
		loopTimes++;

		if (!FileSystem.exists(file))
		{
			var directory = Path.directory(file);

			if (!FileSystem.exists(directory))
				SUtil.mkDirs(directory);

			try
			{
				var assetPath = getFile(file);

				if (OpenFLAssets.exists(assetPath))
				{
					if (textFilesExtensions.contains(Path.extension(file)))
						createContentFromInternal(file);
					else
						File.saveBytes(file, getFileBytes(assetPath));
				}
				else
				{
					failedFiles.push(assetPath + " (Not found)");
					failedFilesStack.push(assetPath);
				}
			}
			catch (e:haxe.Exception)
			{
				failedFiles.push(file + " (" + e.message + ")");
				failedFilesStack.push(file);
			}
		}
	}

	public function createContentFromInternal(file:String)
	{
		try
		{
			var fileData:String = OpenFLAssets.getText(getFile(file));
			if (fileData == null) fileData = '';

			File.saveContent(file, fileData);
		}
		catch (e:haxe.Exception)
		{
			failedFiles.push(file + " (" + e.message + ")");
		}
	}

	public function getFileBytes(file:String):ByteArray
	{
		// 🔥 ARREGLADO PARA ANDROID
		return OpenFLAssets.getBytes(file);
	}

	public static function getFile(file:String):String
	{
		if (OpenFLAssets.exists(file)) return file;

		@:privateAccess
		for (library in LimeAssets.libraries.keys())
		{
			if (OpenFLAssets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}

		return file;
	}

	public static function checkExistingFiles():Bool
	{
		// 🔥 FILTRADO CORRECTO
		locatedFiles = OpenFLAssets.list().filter(f -> f.startsWith('assets/'));

		var filesToRemove:Array<String> = [];

		for (file in locatedFiles)
		{
			if (FileSystem.exists(file))
				filesToRemove.push(file);
		}

		for (file in filesToRemove)
			locatedFiles.remove(file);

		maxLoopTimes = locatedFiles.length;

		return (maxLoopTimes <= 0);
	}
}
#end		var file = locatedFiles[loopTimes];
		loopTimes++;
		if (!FileSystem.exists(file))
		{
			var directory = Path.directory(file);
			if (!FileSystem.exists(directory))
				SUtil.mkDirs(directory);
			try
			{
				if (OpenFLAssets.exists(getFile(file)))
				{
					if (textFilesExtensions.contains(Path.extension(file)))
						createContentFromInternal(file);
					else
						File.saveBytes(file, getFileBytes(getFile(file)));
				}
				else
				{
					failedFiles.push(getFile(file) + " (File Dosen't Exist)");
					failedFilesStack.push('Asset ${getFile(file)} does not exist.');
				}
			}
			catch (e:haxe.Exception)
			{
				failedFiles.push('${getFile(file)} (${e.message})');
				failedFilesStack.push('${getFile(file)} (${e.stack})');
			}
		}
	}

	public function createContentFromInternal(file:String)
	{
		var fileName = Path.withoutDirectory(file);
		var directory = Path.directory(file);
		try
		{
			var fileData:String = OpenFLAssets.getText(getFile(file));
			if (fileData == null)
				fileData = '';
			if (!FileSystem.exists(directory))
				SUtil.mkDirs(directory);
			File.saveContent(Path.join([directory, fileName]), fileData);
		}
		catch (e:haxe.Exception)
		{
			failedFiles.push('${getFile(file)} (${e.message})');
			failedFilesStack.push('${getFile(file)} (${e.stack})');
		}
	}

	public function getFileBytes(file:String):ByteArray
	{
		switch (Path.extension(file))
		{
			case 'otf' | 'ttf':
				return ByteArray.fromFile(file);
			default:
				return OpenFLAssets.getBytes(file);
		}
	}

	public static function getFile(file:String):String
	{
		if(OpenFLAssets.exists(file)) return file;

		@:privateAccess
		for(library in LimeAssets.libraries.keys()){
			if(OpenFLAssets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}

		return file;
	}

	public static function checkExistingFiles():Bool
	{
		locatedFiles = OpenFLAssets.list();
		
		// removes unwanted assets
		locatedFiles = locatedFiles.filter(folder -> folder.startsWith('assets/'));
		//var mods = locatedFiles.filter(folder -> folder.startsWith('mods/'));
		//locatedFiles = assets.concat(mods);

		var filesToRemove:Array<String> = [];

		for (file in locatedFiles)
		{
			if (FileSystem.exists(file) || OpenFLAssets.exists(getFile(Path.join([Path.directory(getFile(file)), IGNORE_FOLDER_FILE_NAME]))))
			{
				filesToRemove.push(file);
			}
		}

		for (file in filesToRemove)
			locatedFiles.remove(file);

		maxLoopTimes = locatedFiles.length;

		return (maxLoopTimes <= 0);
	}
}
#end
