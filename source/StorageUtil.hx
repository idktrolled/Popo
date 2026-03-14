package;

import flixel.util.FlxTimer;

/**
 * A storage class for mobile.
 * @author Karim Akra and Homura Akemi (HomuHomu833)
 */
class StorageUtil
{
	#if sys
	public static function getStorageDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		final folder:String = #if android StorageUtil.getExternalStorageDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				CoolUtil.showPopUp(LanguageBasic.getPhrase('file_save_success', '{1} has been saved.', [fileName]), LanguageBasic.getPhrase('mobile_success', "Success!"));
		}
		catch (e:Dynamic)
			if (alert)
				CoolUtil.showPopUp(LanguageBasic.getPhrase('file_save_fail', '{1} couldn\'t be saved.\n({2})', [fileName, e.message]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}

	#if android
	// always force path due to haxe
	public static function getExternalStorageDirectory():String
		return '/sdcard/.KathyEngine/';

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');

		// 延迟检查权限，给用户时间授予权限
		// 使用 Sys.sleep 而不是 FlxTimer，因为此时 FlxG 可能还未初始化
		Sys.sleep(1.0);

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			CoolUtil.showPopUp(LanguageBasic.getPhrase('permissions_message', 'If you accepted the permissions you are all good!\nIf you didn\'t then expect a crash\nPress OK to see what happens'),
				LanguageBasic.getPhrase('mobile_notice', "Notice!"));

		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp(LanguageBasic.getPhrase('create_directory_error', 'Please create directory to\n{1}\nPress OK to close the game', [StorageUtil.getStorageDirectory()]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'mods'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'mods');
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp(LanguageBasic.getPhrase('create_directory_error', 'Please create directory to\n{1}\nPress OK to close the game', [StorageUtil.getExternalStorageDirectory()]), LanguageBasic.getPhrase('mobile_error', "Error!"));
			lime.system.System.exit(1);
		}
	}
	#end
	#end
}
