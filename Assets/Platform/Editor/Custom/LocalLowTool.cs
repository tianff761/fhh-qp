using UnityEngine;
using UnityEditor;
using System.IO;
using System.Diagnostics;

public class LocalLowTool
{
    [MenuItem("Tools/LocalLow/DeleteAll")]
    private static void DeleteLocalLow()
    {
        Directory.Delete(Application.persistentDataPath, true);
        UnityEngine.Debug.Log("删除完毕");
    }

    [MenuItem("Tools/LocalLow/GoTo")]
    private static void GoTOLocalLow()
    {
        string path = Application.persistentDataPath.Replace("/", @"\");
        Process.Start("explorer.exe", path);
    }
}
