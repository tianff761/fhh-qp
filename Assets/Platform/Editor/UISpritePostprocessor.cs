using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Text.RegularExpressions;
using System.IO;

public class UISpritePostprocessor : AssetPostprocessor
{
    //static string effectPath = "Game/Art/Effects";
    //static string effectFloder = "effect_texture";
    //static string fontFloder1 = "/Font";
    //static string fontFloder2 = "/font";
    //static string SPRITES_DIR = "Assets/Game/Art/Textures/";

    void OnPreprocessTexture()
    {
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        // SetTextureFormat(textureImporter);
        // SetTexturePackingTag(textureImporter, textureImporter.assetPath);
    }

    void OnPostprocessTexture(Texture2D texture)
    {

    }

    private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] moveFromAssetPath)
    {

    }

    //[MenuItem("Assets/将选择文件夹的贴图设置成规定格式")]
    static void SetSelectTextures()
    {
        Object[] selects = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        for (int i = 0; i < selects.Length; ++i)
        {
            Object selected = selects[i];
            string path = AssetDatabase.GetAssetPath(selected);
            AssetImporter asset = AssetImporter.GetAtPath(path);
            TextureImporter textureImporter = asset as TextureImporter;
            if (textureImporter != null)
            {
                SetTextureFormat(textureImporter);
                SetTexturePackingTag(textureImporter, path);
                textureImporter.SaveAndReimport();
            }
        }
        AssetDatabase.Refresh();
    }

    public static void SetTextureFormat(TextureImporter textureImporter)
    {
        textureImporter.isReadable = false;
        textureImporter.mipmapEnabled = false;
        textureImporter.npotScale = TextureImporterNPOTScale.None;
        textureImporter.alphaIsTransparency = true;

        TextureImporterPlatformSettings ios = textureImporter.GetPlatformTextureSettings("iPhone");
        ios.overridden = true;
        ios.format = TextureImporterFormat.ASTC_RGBA_4x4;
        textureImporter.SetPlatformTextureSettings(ios);

        TextureImporterPlatformSettings android = textureImporter.GetPlatformTextureSettings("Android");
        android.overridden = true;
        android.format = TextureImporterFormat.ASTC_RGBA_4x4;
        textureImporter.SetPlatformTextureSettings(android);

        //TextureImporterPlatformSettings pc = textureImporter.GetPlatformTextureSettings("Standalone");
        //pc.overridden = true;
        //pc.format = TextureImporterFormat.RGBA32;
        //textureImporter.SetPlatformTextureSettings(pc);
    }

    private static bool IsNeedAtlas(Texture sprite)
    {
        //int width = sprite.texture.width;
        //int height = sprite.texture.height;
        //if (height > 1024 & width > 512)
        //{
        //    return false;
        //}
        //else if (width > 1024 & height > 512)
        //{
        //    return false;
        //}
        //else if (width <= 2048 & height <= 2048)
        //{
        //    return true;
        //}
        return false;
    }

    //private static bool IsEffectAssets(string path)
    //{
    //    path = path.Replace("\\", "/");
    //    return path.Contains(effectPath) || path.Contains(effectFloder) || path.Contains(fontFloder1) || path.Contains(fontFloder2);
    //}

    private static void SetAssetsPackingTag(string[] assets)
    {
        for (int i = 0; i < assets.Length; ++i)
        {
            string path = assets[i];
            var textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
            if (textureImporter && textureImporter.textureType == TextureImporterType.Sprite)
            {
                if (SetTexturePackingTag(textureImporter, path))
                    textureImporter.SaveAndReimport();
            }
        }
    }

    public static bool SetTexturePackingTag(TextureImporter textureImporter, string path)
    {
        bool needChange = false;
        string tag = GetSpritePackingTag(path);
        //Texture2D sprite = AssetDatabase.LoadMainAssetAtPath(path) as Texture2D;
        //Debug.Log(sprite);
        //if (!IsNeedAtlas(sprite))
        //{
        //    tag = "";
        //}
        if (tag != textureImporter.spritePackingTag)
        {
            textureImporter.spritePackingTag = tag;
            needChange = true;
        }
        return needChange;
    }

    public static string GetSpritePackingTag(string path)
    {
        string dirName = Path.GetDirectoryName(path);
        dirName = dirName.Substring(dirName.LastIndexOf("/") + 1);
        return dirName;
    }
}