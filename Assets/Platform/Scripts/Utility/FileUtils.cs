using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using LuaFramework;

public class FileUtils
{
    public static bool ExistsFile(string file)
    {
        return File.Exists(file);
    }

    public static bool ExistsDir(string dir)
    {
        return Directory.Exists(dir);
    }

    public static void CreateDir(string path)
    {
        Directory.CreateDirectory(path);
    }

    /// <summary>
    /// 检测和创建目录
    /// </summary>
    /// <param name="path"></param>
    public static void CheckCrateDir(string path)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
    }

    public static string GetDirByFile(string file)
    {
        return Path.GetDirectoryName(file);
    }

    public static string GetReadWritePath()
    {
        return Assets.RuntimeAssetsPath;
    }

    public static string Md5File(string file)
    {
        return Util.md5file(file);
    }

    /// <summary>
    /// 删除文件
    /// </summary>
    public static void DeleteFile(string filepath)
    {
        try
        {
            if (File.Exists(filepath))
            {
                File.Delete(filepath);
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 获取文件的文本内容
    /// </summary>
    public static string GetFileText(string filePath)
    {
        try
        {
            if (File.Exists(filePath))
            {
                return File.ReadAllText(filePath);
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
        return null;
    }

    public static void CopyFile(string filePath, string toFilePath, bool overwrite)
    {
        try
        {
            if (File.Exists(filePath))
            {
                File.Copy(filePath, toFilePath, overwrite);
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
            throw;
        }
    }
    public static string[] ReadAllLines(string filePath)
    {
        try
        {
            string[] allLine = File.ReadAllLines(filePath);
            return allLine;
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
        return null;
    }
    public static void WriteLine(string filePath, string text, int value)
    {
        try
        {
            FileMode mode = (FileMode)value;
            FileStream aFile = new FileStream(filePath, mode);
            StreamWriter sw = new StreamWriter(aFile);
            sw.WriteLine(text);
            sw.Close();
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 检测路径格式
    /// </summary>
    public static string CheckDirectoryFormat(string dirPath)
    {
        if (string.IsNullOrEmpty(dirPath))
        {
            return dirPath;
        }
        dirPath = dirPath.Replace("\\", "/");
        if (!dirPath.EndsWith("/"))
        {
            dirPath += "/";
        }
        return dirPath;
    }


    /// <summary>
    /// 使用文件流的方式写入文件
    /// </summary>
    public static void WriteFile(string filePath, byte[] bytes)
    {
        if (bytes == null || bytes.Length < 1)
        {
            return;
        }
        if (string.IsNullOrEmpty(filePath))
        {
            return;
        }

        try
        {
            FileInfo fileInfo = new FileInfo(filePath);
            if (!fileInfo.Directory.Exists)
            {
                fileInfo.Directory.Create();
            }
            //由于设置了文件共享模式为允许随后写入，所以即使多个线程同时写入文件，也会等待之前的线程写入结束之后再执行，而不会出现错误
            using (FileStream fileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.ReadWrite))
            {
                fileStream.Seek(0, SeekOrigin.Begin);
                fileStream.Write(bytes, 0, bytes.Length);
                fileStream.Close();
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 保存到文件
    /// </summary>
    public static void SaveToFile(string filePath, byte[] bytes)
    {
        WriteFile(filePath, bytes);
    }

    /// <summary>
    /// 保存到文件
    /// </summary>
    public static void SaveToFile(string filePath, string text)
    {
        if (text == null)
        {
            return;
        }

        try
        {
            byte[] bytes = Encoding.UTF8.GetBytes(text);
            WriteFile(filePath, bytes);
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 获取文件的字节数组
    /// </summary>
    public static byte[] ReadAllBytes(string filePath)
    {
        try
        {
            if (File.Exists(filePath))
            {
                using (FileStream fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    byte[] buffer = new byte[fileStream.Length];
                    fileStream.Position = 0;
                    fileStream.Read(buffer, 0, buffer.Length);
                    fileStream.Close();

                    return buffer;
                }
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
        return null;
    }

    /// <summary>
    /// 获取文件的文本内容
    /// </summary>
    public static string ReadAllText(string filePath)
    {
        byte[] bytes = ReadAllBytes(filePath);
        if (bytes != null)
        {
            return Encoding.UTF8.GetString(bytes);
        }
        return null;
    }
}
