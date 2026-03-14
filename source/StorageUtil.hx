package;

#if sys
import sys.*;
import sys.io.*;
#end
import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end
using StringTools;

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
				CoolUtil.showPopUp(fileName + " has been saved.", "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				CoolUtil.showPopUp(fileName + " couldn't be saved.\n(" + e.message + ")", "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}

	#if android
	// always force path due to haxe
	public static function getExternalStorageDirectory():String
		return '/sdcard/.PsychEngine/';

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			CoolUtil.showPopUp("If you accepted the permissions you are all good!\nIf you didn't then expect a crash\nPress OK to see what happens", "Notice!");

		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp("Please create directory to\n" + StorageUtil.getStorageDirectory() + "\n\nPress OK to close the game", "Error!");
			lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'mods'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'mods');
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp("Please create directory to\n" + StorageUtil.getExternalStorageDirectory() + "\nPress OK to close the game", "Error!");
			lime.system.System.exit(1);
		}
	}
	#end
	#end
}
