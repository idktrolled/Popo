package;
import flixel.util.FlxTimer;
#if android
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
#end
class StorageUtil
{
	#if sys
	public static function getStorageDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;
	public static function showPopUp(message:String, title:String):Void
	{
		FlxG.stage.window.alert(message, title);
	}
	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		final folder:String = #if android StorageUtil.getExternalStorageDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				showPopUp(LanguageBasic.getPhrase('file_save_success', '{1} has been saved.', [fileName]), LanguageBasic.getPhrase('mobile_success', "Success!"));
		}
		catch (e:Dynamic)
			if (alert)
				showPopUp(LanguageBasic.getPhrase('file_save_fail', '{1} couldn\'t be saved.\n({2})', [fileName, e.message]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#if android
	public static function getExternalStorageDirectory():String
		return '/sdcard/.QTmod/';
	public static function requestPermissions():Void
	{
		if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU)
			Permissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED']);
		else
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!Environment.isExternalStorageManager())
			Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		
		Sys.sleep(1.0);

		if ((VERSION.SDK_INT >= VERSION_CODES.TIRAMISU
			&& !Permissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (VERSION.SDK_INT < VERSION_CODES.TIRAMISU
				&& !Permissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			showPopUp(LanguageBasic.getPhrase('permissions_message', 'If you accepted the permissions you are all good!\nIf you didn\'t then expect a crash\nPress OK to see what happens'),
				LanguageBasic.getPhrase('mobile_notice', "Notice!"));
		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			showPopUp(LanguageBasic.getPhrase('create_directory_error', 'Please create directory to\n{1}\nPress OK to close the game', [StorageUtil.getStorageDirectory()]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'mods'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'mods');
		}
		catch (e:Dynamic)
		{
			showPopUp(LanguageBasic.getPhrase('create_directory_error', 'Please create directory to\n{1}\nPress OK to close the game', [StorageUtil.getExternalStorageDirectory()]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			lime.system.System.exit(1);
		}
	}
	#end
	#end
}
