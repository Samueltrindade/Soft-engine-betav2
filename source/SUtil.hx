package;

#if android
import android.AndroidTools;
import android.stuff.Permissions;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import flash.system.System;

/**
 * author: Saw (M.A. Jigsaw)
 */

using StringTools;

class SUtil {
	#if android
	private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions(); // granted Permissions
	private static var aDir:String = null; // android dir 
	private static var sPath:String = AndroidTools.getExternalStorageDirectory(); // storage dir
	#end

	static public function getPath():String {
		#if android
		if (aDir != null && aDir.length > 0) {
			return aDir;
		} else {
			aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/";
		}
		return aDir;
		#else
		return "";
		#end
	}

	static public function doTheCheck() {
		#if android
		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
			}
		}

		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				SUtil.applicationAlert("Permissions", "Se tu ja aceitou a permissao de armazenamento, ok de boa continue mas se o jogo n funcionar, olhe as configuracoes do app" 
					+ "\n" + "Aperte Ok pra fechar o app");
			} else {
				SUtil.applicationAlert("Permissions", "O jogo n roda sem permissao de armazenamento" 
					+ "\n" + "Aperte Ok pra sair do app");
			}
		}

		if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
			FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
		}
		if (!FileSystem.exists(SUtil.getPath() + "crash")){
			FileSystem.createDirectory(SUtil.getPath() + "crash");
		}
		if (!FileSystem.exists(SUtil.getPath() + "saves")){
			FileSystem.createDirectory(SUtil.getPath() + "saves");
		}
		if (!FileSystem.exists(SUtil.getPath() + "mods") && !FileSystem.exists(SUtil.getPath() + "assets")){
			File.saveContent(SUtil.getPath() + "Coloque a pasta Assets e Mods aqui.txt", "Oi tu leu o nome do arquivo?");
		}
		if (!FileSystem.exists(SUtil.getPath() + "assets")){
			SUtil.applicationAlert("Instructions:", "Leia o arquivo que deixei na pasta"
				+ " ( here " + SUtil.getPath() + " )" 
				+ " N sabe como faz isso? procura um tutorial no YouTube " 
				+ "\n" + "Aperte Ok para fechar o app");
			System.exit(0);
		}
		if (!FileSystem.exists(SUtil.getPath() + "mods")){
			SUtil.applicationAlert("Instructions:", "Leia o arquivo que deixei na pasta" 
				+ " ( here " + SUtil.getPath() + " )" 
				+ " N sabe como faz isso? procura um tutorial no YouTube" 
				+ "\n" + "Aperte Ok para fechar o app");
			System.exit(0);
		}
		if (FileSystem.exists(SUtil.getPath() + "Coloque a pasta Assets e Mods aqui.txt") && FileSystem.exists(SUtil.getPath() + "mods") && FileSystem.exists(SUtil.getPath() + "assets")){
			FileSystem.deleteFile(SUtil.getPath() + "Coloque a pasta Assets e Mods aqui.txt");
		}
		#end
	}

	static public function gameCrashCheck() {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	static public function onCrash(e:UncaughtErrorEvent):Void {
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");
		var path:String = "crash/" + "crash_" + dateNow + ".txt";
		var errMsg:String = "";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		if (!FileSystem.exists(SUtil.getPath() + "crash")){
			FileSystem.createDirectory(SUtil.getPath() + "crash");
		}

		File.saveContent(SUtil.getPath() + path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Sys.println("Making a simple alert ...");

		SUtil.applicationAlert("Uncaught Error :(, The Call Stack: ", errMsg);
		System.exit(0);
	}

	private static function applicationAlert(title:String, description:String) {
		Application.current.window.alert(description, title);
	}

	#if android
	static public function saveContent(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
		if (!FileSystem.exists(SUtil.getPath() + "saves")){
			FileSystem.createDirectory(SUtil.getPath() + "saves");
		}

		File.saveContent(SUtil.getPath() + "saves/" + fileName + fileExtension, fileData);
		SUtil.applicationAlert("Feito :)", "SALVEMO!");
	}

	static public function saveClipboard(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
		openfl.system.System.setClipboard(fileData);
		SUtil.applicationAlert("Feito :)", "Salvemo no copia e cola!");
	}

	static public function copyContent(copyPath:String, savePath:String) {
		if (!FileSystem.exists(savePath)){
			var bytes = OpenFlAssets.getBytes(copyPath);
			File.saveBytes(savePath, bytes);
		}
	}
	#end
}
