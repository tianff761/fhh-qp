using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using System.Text;


/*******************************************************************************
 * 
 *             类名: DataAssetsTool
 *             功能: 数据资源工具，用于发布时需要处理的资源
 *             作者: HGQ
 *             日期:
 *             修改:
 *             
 * *****************************************************************************/

public class DataAssetsTool
{

    private const string ASSETS_TYPE_EDITOR_SIMULATE = "DataAssets/Editor";
    private const string ASSETS_TYPE_STREAMINGASSETS = "DataAssets/StreamingAssets";
    private const string ASSETS_TYPE_RELEASE_SIMULATE = "DataAssets/Release";


    /// <summary>
    /// 资源是否为编辑器下标记的资源
    /// </summary>
    [MenuItem(ASSETS_TYPE_EDITOR_SIMULATE)]
    public static void ToggleSimulationEditorMode()
    {
        EditorConst.editorAssetsType = EditorAssetsType.Editor;
    }

    [MenuItem(ASSETS_TYPE_EDITOR_SIMULATE, true, 1000)]
    public static bool ToggleSimulationEditorModeValidate()
    {
        Menu.SetChecked(ASSETS_TYPE_EDITOR_SIMULATE, EditorConst.editorAssetsType == EditorAssetsType.Editor);
        return true;
    }

    /// <summary>
    /// 资源是否为StreamAssets下的资源
    /// </summary>
    [MenuItem(ASSETS_TYPE_STREAMINGASSETS)]
    public static void ToggleStreamingAssetsMode()
    {
        EditorConst.editorAssetsType = EditorAssetsType.StreamingAssets;
    }

    [MenuItem(ASSETS_TYPE_STREAMINGASSETS, true, 1001)]
    public static bool ToggleStreamingAssetsModeValidate()
    {
        Menu.SetChecked(ASSETS_TYPE_STREAMINGASSETS, EditorConst.editorAssetsType == EditorAssetsType.StreamingAssets);
        return true;
    }


    /// <summary>
    /// 资源是否为发布资源即可读写文件夹下的资源
    /// </summary>
    [MenuItem(ASSETS_TYPE_RELEASE_SIMULATE)]
    public static void ToggleSimulationMode()
    {
        EditorConst.editorAssetsType = EditorAssetsType.Release;
    }

    [MenuItem(ASSETS_TYPE_RELEASE_SIMULATE, true, 1002)]
    public static bool ToggleSimulationModeValidate()
    {
        Menu.SetChecked(ASSETS_TYPE_RELEASE_SIMULATE, EditorConst.editorAssetsType == EditorAssetsType.Release);
        return true;
    }


    //======================================================================

    /// <summary>
    /// 生成资源清单文件
    /// </summary>
    //[MenuItem("DataAssets/Generate List File")]
    //public static void GenerateListFile()
    //{
    //    string dataAssetsDirPath = Application.streamingAssetsPath.Replace("\\", "/") + "/DataAssets/";

    //    string listFilePath = dataAssetsDirPath + "list.agt";
    //    if (File.Exists(listFilePath))
    //    {
    //        File.Delete(listFilePath);
    //    }

    //    DirectoryInfo dirInfo = new DirectoryInfo(dataAssetsDirPath);
    //    FileInfo[] fileInfos = dirInfo.GetFiles("*.*", SearchOption.AllDirectories);

    //    UpdateListFileData updateListFileData = new UpdateListFileData();


    //    for (int i = 0; i < fileInfos.Length; i++)
    //    {
    //        FileInfo fileInfo = fileInfos[i];
    //        if (".meta".Equals(fileInfo.Extension))
    //        {
    //            continue;
    //        }

    //        string fileName = fileInfo.FullName.Replace("\\", "/").Replace(dataAssetsDirPath, "");

    //        UpdateListFileItemData itemData = new UpdateListFileItemData();
    //        itemData.name = fileName;
    //        itemData.md5 = SecurityUtil.GetFileMD5(fileInfo.FullName);
    //        itemData.size = fileInfo.Length;//Byte

    //        updateListFileData.list.Add(itemData);
    //    }

    //    string json = JsonHelper.Serialize(updateListFileData);

    //    File.WriteAllText(listFilePath, json);
    //    Debug.Log("生成完成！");
    //}

    //======================================================================



}
