using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 文件引用情况编辑器工具
/// </summary>
public class FileReferenceTool
{

    /// <summary>
    /// 使用前请确保GetAllTextureInfosInPrefabs被调用
    /// key：文件的Guid，value：文件被引用的Prefab路径
    /// </summary>
    private static Dictionary<string, List<string>> mFileDependenciesDict = new Dictionary<string, List<string>>();
    /// <summary>
    /// 获取所有Prefab引用的文件
    /// </summary>
    public static void GetFilesInAllPrefabs()
    {
        mFileDependenciesDict.Clear();
        string[] files = AssetDatabase.GetAllAssetPaths();
        List<string> list = null;
        string guid = null;
        foreach (string file in files)
        {
            if (file.EndsWith(".prefab"))
            {
                string[] dependencies = AssetDatabase.GetDependencies(file);
                foreach (string str in dependencies)
                {
                    guid = AssetDatabase.AssetPathToGUID(str);
                    if (mFileDependenciesDict.TryGetValue(guid, out list))
                    {
                        list.Add(file);
                    }
                    else
                    {
                        list = new List<string>();
                        mFileDependenciesDict.Add(guid, list);
                        list.Add(file);
                    }
                }
            }
        }
    }
    /// <summary>
    /// 获取所有Prefab引用的指定资源，图片（png、jpg）、字体（ttf、ttc）、Prefab
    /// </summary>
    public static void GetAssetsInAllPrefabs()
    {
        mFileDependenciesDict.Clear();
        string[] files = AssetDatabase.GetAllAssetPaths();
        string temp = null;
        List<string> list = null;
        string guid = null;
        foreach (string file in files)
        {
            if (file.EndsWith(".prefab"))
            {
                string[] dependencies = AssetDatabase.GetDependencies(file);
                foreach (string str in dependencies)
                {
                    temp = str.ToLower();
                    if (temp.EndsWith(".png") || temp.EndsWith(".jpg") || temp.EndsWith(".ttf")
                        || temp.EndsWith(".ttc") || temp.EndsWith(".prefab"))
                    {
                        guid = AssetDatabase.AssetPathToGUID(str);
                        if (mFileDependenciesDict.TryGetValue(guid, out list))
                        {
                            list.Add(file);
                        }
                        else
                        {
                            list = new List<string>();
                            mFileDependenciesDict.Add(guid, list);
                            list.Add(file);
                        }
                    }
                }
            }
        }
    }

    /// <summary>
    /// 获取节点路径
    /// </summary>
    public static string GetGameObjectPath(Transform transform)
    {
        string result = transform.name;
        if (transform.parent != null)
        {
            result = GetGameObjectPath(transform.parent) + "/" + result;
        }
        return result;
    }

    /// <summary>
    /// 打印红色日志输出
    /// </summary>
    public static void LogRedColor(string str)
    {
        Debug.Log("<color=#FF0000>" + str + "</color>");
    }
    /// <summary>
    /// 打印红色日志输出
    /// </summary>
    public static void LogRedColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#FF0000>" + str + "</color>", obj);
    }

    /// <summary>
    /// 打印橙色日志输出
    /// </summary>
    public static void LogOrangeColor(string str)
    {
        Debug.Log("<color=#F07800>" + str + "</color>");
    }

    /// <summary>
    /// 打印橙色日志输出
    /// </summary>
    public static void LogOrangeColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#F07800>" + str + "</color>", obj);
    }
    /// <summary>
    /// 打印绿色日志输出
    /// </summary>
    public static void LogGreenColor(string str)
    {
        Debug.Log("<color=#00FF00>" + str + "</color>");
    }

    /// <summary>
    /// 打印绿色日志输出
    /// </summary>
    public static void LogGreenColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#00FF00>" + str + "</color>", obj);
    }


    /// <summary>
    /// 检测单个文件被引用情况，并打印出引用情况
    /// </summary>
    /// <param name="path">文件路径</param>
    public static void CheckReferenceBySingleFile(string path)
    {
        string guid = AssetDatabase.AssetPathToGUID(path);
        List<string> list = null;
        string temp = null;
        if (mFileDependenciesDict.TryGetValue(guid, out list))
        {
            for (int i = 0; i < list.Count; i++)
            {
                temp = list[i];
                FileReferenceTool.LogRedColor(temp, AssetDatabase.LoadAssetAtPath<GameObject>(temp));
            }
        }
    }

    /// <summary>
    /// 是否被引用
    /// </summary>
    /// <param name="path">文件路径</param>
    public static bool IsReferenceBySingleFile(string path) 
    {
        string guid = AssetDatabase.AssetPathToGUID(path);
        return mFileDependenciesDict.ContainsKey(guid);
    }

    //================================================================
    //================================================================

    [MenuItem("Assets/FileReference/查找文件在Prefab引用情况")]
    private static void CheckFileReference()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (string.IsNullOrEmpty(path))
        {
            Debug.LogError("请选择需要查找的文件！");
            return;
        }
        FileReferenceTool.GetFilesInAllPrefabs();
        FileReferenceTool.LogOrangeColor("================[查找文件在Prefab引用情况-开始]================");
        FileReferenceTool.LogOrangeColor(">> 查找的资源对象路径 > " + path, Selection.activeObject);
        FileReferenceTool.CheckReferenceBySingleFile(path);
        FileReferenceTool.LogGreenColor("================<查找文件在Prefab引用情况-结束>================");
    }

    [MenuItem("Assets/FileReference/查找选中文件及文件夹下图片在Prefab引用情况")]
    private static void CheckTextureReference()
    {
        UnityEngine.Object[] selection = Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.DeepAssets);

        if (selection.Length < 1)
        {
            Debug.LogError("请选择需要查找的文件或文件夹！");
            return;
        }
        FileReferenceTool.GetAssetsInAllPrefabs();
        FileReferenceTool.LogOrangeColor("================[查找选中文件及文件夹下图片在Prefab引用情况-开始]================");
        UnityEngine.Object obj;
        string filePath;
        string temp;
        for (int i = 0; i < selection.Length; i++)
        {
            obj = selection[i];
            filePath = AssetDatabase.GetAssetPath(obj);
            temp = filePath.ToLower();
            if (temp.EndsWith(".png") || temp.EndsWith(".jpg"))
            {
                FileReferenceTool.LogOrangeColor(">> 查找的资源对象路径 > " + filePath, obj);
                FileReferenceTool.CheckReferenceBySingleFile(filePath);
            }
        }
        FileReferenceTool.LogGreenColor("================<查找选中文件及文件夹下图片在Prefab引用情况-结束>================");
    }

    [MenuItem("Assets/FileReference/移除选中文件及文件夹下未被引用的图片")]
    private static void DeleteTextureByNotReference()
    {
        UnityEngine.Object[] selection = Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.DeepAssets);

        if (selection.Length < 1)
        {
            Debug.LogError("请选择需要移除的文件或需要检测的文件夹！");
            return;
        }
        FileReferenceTool.GetAssetsInAllPrefabs();
        FileReferenceTool.LogOrangeColor("================[移除选中文件及文件夹下未被引用的图片-开始]================");
        UnityEngine.Object obj;
        string filePath;
        string temp;
        List<string> deleteList = new List<string>();
        for (int i = 0; i < selection.Length; i++)
        {
            obj = selection[i];
            filePath = AssetDatabase.GetAssetPath(obj);
            temp = filePath.ToLower();
            if (temp.EndsWith(".png") || temp.EndsWith(".jpg"))
            {
                if (!FileReferenceTool.IsReferenceBySingleFile(filePath)) 
                {
                    deleteList.Add(filePath);
                }
            }
        }
        if (deleteList.Count > 0) 
        {
            for (int i = 0; i < deleteList.Count; i++) 
            {
                filePath = deleteList[i];
                FileReferenceTool.LogRedColor(">> 删除图片 > " + filePath);
                AssetDatabase.DeleteAsset(filePath);
            }
            AssetDatabase.Refresh();
        }
        FileReferenceTool.LogGreenColor("================<移除选中文件及文件夹下未被引用的图片-结束>================");
    }
}