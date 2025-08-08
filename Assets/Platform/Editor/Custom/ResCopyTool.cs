using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ResCopyTool
{

    [MenuItem("Build Resources/Copy Res To Folder", false, 88889)]
    private static void CopyResToFolder()
    {
        _CopyResToFolder();
        EditorUtility.DisplayDialog("Copy Res To Folder", "Copy Completed！", "确定");
    }

    private static void _CopyResToFolder()
    {
        string resPath = FileUtils.CheckDirectoryFormat(Application.streamingAssetsPath) + "res/";
        string targetPath = GetCopyBuildFolderPath() + "res/";
        //
        if (Directory.Exists(targetPath))
        {
            Directory.Delete(targetPath, true);
        }
        Directory.CreateDirectory(targetPath);
        //
        DirectoryInfo directoryInfo = new DirectoryInfo(resPath);
        FileInfo[] fileInfos = directoryInfo.GetFiles("*.*", SearchOption.AllDirectories);
        FileInfo fileInfo = null;
        string fullName = null;
        string extension = null;
        string newFullPath = null;
        string newFolder = null;
        for (int i = 0; i < fileInfos.Length; i++)
        {
            fileInfo = fileInfos[i];
            extension = fileInfo.Extension;
            Debug.Log(fileInfo.FullName + " , " + extension);
            if (extension == null || extension == "" || extension == ".meta" || extension == ".manifest")
            {
                continue;
            }
            fullName = fileInfo.FullName.Replace("\\", "/");
            newFullPath = targetPath + fullName.Replace(resPath, "");
            newFolder = targetPath + fileInfo.DirectoryName.Replace("\\", "/").Replace(resPath, "");
            if (!Directory.Exists(newFolder))
            {
                Directory.CreateDirectory(newFolder);
            }
            fileInfo.CopyTo(newFullPath, true);
        }
    }

    /// <summary>
    /// 获取拷贝文件夹路径
    /// </summary>
    public static string GetCopyBuildFolderPath()
    {
        string projectPath = FileUtils.CheckDirectoryFormat(Application.dataPath).Replace("Assets/", "");

        string configPath = projectPath + "BuildConfig.txt";
        string temp = null;
        if (File.Exists(configPath))
        {
            temp = File.ReadAllText(configPath);
        }
        if (string.IsNullOrEmpty(temp))
        {
            temp = projectPath;
        }
        string path = EditorUtility.OpenFolderPanel("请选择拷贝目录", temp, "");
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        path = path.Replace("\\", "/");
        if (!path.EndsWith("/"))
        {
            path += "/";
        }
        File.WriteAllText(configPath, path);
        return path;
    }
}
