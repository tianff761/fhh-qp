using UnityEditor;
using UnityEngine;
using System.IO;

public class CreateVersionTool : EditorWindow
{
    [MenuItem("Build Resources/Create Version", false, 90000)]
    private static void AddShowWindow()
    {
        ShowWindow();
    }

    static string streamAssetPath;
    static CreateVersionTool window;
    string version = "1.0.1";
    private void Awake()
    {
        streamAssetPath = Application.streamingAssetsPath + "/res/";
    }

    private static void ShowWindow()
    {
        Rect wr = new Rect(0, 0, 300, 50);
        window = (CreateVersionTool)GetWindowWithRect(typeof(CreateVersionTool), wr, true, "请输入资源版本号");
        window.Show();
    }

    private void OnGUI()
    {
        version = EditorGUILayout.TextField("资源版本号：", version, GUILayout.MaxWidth(500), GUILayout.MaxHeight(20));
        if (GUILayout.Button("生成", GUILayout.MaxWidth(200), GUILayout.MaxHeight(20)))
        {
            OnClickCreate();
            AssetDatabase.Refresh();
            AssetDatabase.SaveAssets();
            window.Close();
        }
    }
    private void OnClickCreate()
    {
        if (Directory.Exists(streamAssetPath))
        {
            DirectoryInfo di = new DirectoryInfo(streamAssetPath);
            DirectoryInfo[] dirs = di.GetDirectories();
            for (int i = 0; i < dirs.Length; i++)
            {
                File.WriteAllText(dirs[i].FullName + "/version.txt", version);
            }
            Debug.Log("生成完成");
        }
        else
        {
            Debug.LogError(streamAssetPath + " is no Exists");
        }
    }
}