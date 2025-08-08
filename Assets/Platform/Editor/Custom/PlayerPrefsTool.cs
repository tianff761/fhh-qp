using UnityEngine;
using UnityEditor;

/// <summary>
/// PlayerPrefs处理工具
/// </summary>
public class PlayerPrefsTool
{

    [MenuItem("Tools/PlayerPrefs/Clear")]
    private static void ClearPlayerPrefs()
    {
        PlayerPrefs.DeleteAll();
        Debug.Log(">> PlayerPrefs > Delete All.");
    }

}
