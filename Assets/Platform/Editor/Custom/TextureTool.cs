using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

/// <summary>
/// 贴图处理工具
/// </summary>
public class TextureTool
{
    [MenuItem("Assets/Texture/设置选中文件及文件夹下图片格式为RGBA32")]
    private static void AssetsHandleSelectedSpritesRGBA32()
    {
        ModifyTextureFormat(TextureImporterFormat.RGBA32);
    }

    [MenuItem("Assets/Texture/设置选中文件及文件夹下PNG图片格式为RGB24")]
    private static void AssetsHandleSelectedPngSpritesRGB24()
    {
        ModifyTextureFormat(TextureImporterFormat.RGB24, ".png");
    }

    [MenuItem("Assets/Texture/设置选中文件及文件夹下JPG图片格式为RGB24")]
    private static void AssetsHandleSelectedJpgSpritesRGB24()
    {
        ModifyTextureFormat(TextureImporterFormat.RGB24, ".jpg");
    }

    [MenuItem("Assets/Texture/检测设置选中文件及文件夹下的图片以文件夹名称为Packing Tag")]
    private static void AssetsHandleSelectedSpritesPackingTag()
    {
        ModifyTextureToSpriteAndSetTag(false);
    }

    [MenuItem("Assets/Texture/强制设置选中文件及文件夹下的图片以文件夹名称为Packing Tag")]
    private static void AssetsHandleSelectedSpritesPackingTagByForce()
    {
        ModifyTextureToSpriteAndSetTag(true);
    }

    //================================================================
    //================================================================


    /// <summary>
    /// 修改文件及文件夹下的图片格式
    /// </summary>
    private static void ModifyTextureFormat(TextureImporterFormat importerFormat, string fileFormat = null)
    {
        Object[] selection = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (selection.Length > 0)
        {
            foreach (Object obj in selection)
            {
                ModifyTextureFormatBySingleObject(obj, importerFormat, fileFormat);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            //提示
            if (selection.Length > 1)
            {
                EditorUtility.DisplayDialog("修改文件及文件夹下的图片格式", "修改文件及文件夹下的图片格式完成！", "确定");
            }
            else
            {
                Debug.LogError("修改文件及文件夹下的图片格式完成");
            }
        }
        else
        {
            Debug.LogError("请选择文件或文件夹！");
        }
    }

    /// <summary>
    /// 修改单个文件的图片格式
    /// </summary>
    private static void ModifyTextureFormatBySingleObject(Object obj, TextureImporterFormat importerFormat, string fileFormat)
    {
        string path = AssetDatabase.GetAssetPath(obj);
        string temp = path.ToLower();
        bool isFit = false;
        if (fileFormat == null)
        {
            isFit = temp.EndsWith(".png") || temp.EndsWith(".jpg");
        }
        else
        {
            isFit = temp.EndsWith(fileFormat);
        }

        if (isFit)
        {
            TextureImporterPlatformSettings platformSettings = null;
            TextureImporter textureImporter = TextureImporter.GetAtPath(path) as TextureImporter;

            if (textureImporter != null)
            {
                TextureImporterPlatformSettings textureImporterPlatformSettings = new TextureImporterPlatformSettings();
                textureImporterPlatformSettings.format = importerFormat;
                textureImporterPlatformSettings.overridden = true;

                textureImporterPlatformSettings.name = "Standalone";
                platformSettings = textureImporter.GetPlatformTextureSettings(textureImporterPlatformSettings.name);
                textureImporterPlatformSettings.maxTextureSize = platformSettings.maxTextureSize;
                textureImporter.SetPlatformTextureSettings(textureImporterPlatformSettings);

                textureImporterPlatformSettings.name = "iPhone";
                platformSettings = textureImporter.GetPlatformTextureSettings(textureImporterPlatformSettings.name);
                textureImporterPlatformSettings.maxTextureSize = platformSettings.maxTextureSize;
                textureImporter.SetPlatformTextureSettings(textureImporterPlatformSettings);

                textureImporterPlatformSettings.name = "Android";
                platformSettings = textureImporter.GetPlatformTextureSettings(textureImporterPlatformSettings.name);
                textureImporterPlatformSettings.maxTextureSize = platformSettings.maxTextureSize;
                textureImporter.SetPlatformTextureSettings(textureImporterPlatformSettings);

                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            }
            else
            {
                Debug.LogError(">> ModifyTextureFormatBySingleObject > " + path);
            }
        }
    }

    /// <summary>
    /// 修改贴图为Sprite并设置Packing Tag
    /// </summary>
    /// <param name="isForce">如果Tag与设置的相同就不进行处理，强制就会处理，否则不处理</param>
    /// <param name="tag">参数为null时取文件夹名称</param>
    private static void ModifyTextureToSpriteAndSetTag(bool isForce, string tag = null)
    {
        Object[] selection = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (selection.Length > 0)
        {
            foreach (Object obj in selection)
            {
                ModifyTextureToSpriteAndSetTagBySingleObject(obj, isForce, tag);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            //提示
            if (selection.Length > 1)
            {
                EditorUtility.DisplayDialog("修改PackingTag", "修改贴图为Sprite并设置Packing Tag完成！", "确定");
            }
            else
            {
                Debug.LogError("修改贴图为Sprite并设置Packing Tag完成！");
            }
        }
        else
        {
            Debug.LogError("请选择文件或文件夹！");
        }
    }

    /// <summary>
    /// 通过单个文件处理
    /// </summary>
    private static void ModifyTextureToSpriteAndSetTagBySingleObject(Object obj, bool isForce, string tag)
    {
        string path = AssetDatabase.GetAssetPath(obj);
        string temp = path.ToLower();
        if (path.EndsWith(".png") || path.EndsWith(".jpg"))
        {
            TextureImporter textureImporter = TextureImporter.GetAtPath(path) as TextureImporter;
            if (textureImporter != null)
            {
                string packingTagName = tag;
                if (string.IsNullOrEmpty(packingTagName))
                {
                    FileInfo info = new FileInfo(path);
                    DirectoryInfo dir = new DirectoryInfo(info.DirectoryName);
                    packingTagName = dir.Name;
                }
                if (isForce || textureImporter.spritePackingTag != packingTagName)
                {
                    textureImporter.mipmapEnabled = false;
                    textureImporter.textureType = TextureImporterType.Sprite;
                    textureImporter.spriteImportMode = SpriteImportMode.Single;
                    textureImporter.alphaIsTransparency = true;
                    textureImporter.wrapMode = TextureWrapMode.Clamp;
                    textureImporter.spritePackingTag = packingTagName;
                    AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
                }
            }
            else
            {
                Debug.LogError(">> ModifyTextureToSpriteAndSetTagBySingleObject > " + path);
            }
        }
    }

}