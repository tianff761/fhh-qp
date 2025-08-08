using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ConfigTool : MonoBehaviour {

	[MenuItem("Build Resources/Encrypt Config", false, 90001)]
	private static void HandleConfig() 
	{
		string path = FileUtils.CheckDirectoryFormat(Application.dataPath) + "Platform/Project/Config/Config.txt";
		byte[] bytes = FileUtils.ReadAllBytes(path);
		if (bytes != null)
		{
			byte[] newBytes = ExceptionUtil.Encode(bytes);
			string savePath = FileUtils.CheckDirectoryFormat(Application.streamingAssetsPath) + "Config.txt";
			FileUtils.SaveToFile(savePath, newBytes);

			EditorUtility.DisplayDialog("Encrypt Config", "Encrypt Config完成！", "确定");
		}
		else 
		{
			EditorUtility.DisplayDialog("Encrypt Config", "Encrypt Config 未找到源文件！", "确定");
		}
	}
}
