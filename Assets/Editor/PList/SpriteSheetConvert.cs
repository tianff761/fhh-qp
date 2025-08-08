using UnityEngine;
using UnityEditor;
using System.IO;
using System.Xml;
using System.Collections;
using System.Collections.Generic;
using Data;
using UnityEditor.Sprites;

public class TPFrameData
{
    public string name;
    public Rect frame;
    public Vector2 offset;
    public bool rotated;
    public Rect sourceColorRect;
    public Vector2 sourceSize;

    public void LoadX(string sname, PList plist)
    {
        name = sname;
        object varCheck;
        if (plist.TryGetValue("frame", out varCheck))
        {
            frame = TPAtlas.StrToRect(plist["frame"] as string);
            offset = TPAtlas.StrToVec2(plist["offset"] as string);
            sourceColorRect = TPAtlas.StrToRect(plist["sourceColorRect"] as string);
            sourceSize = TPAtlas.StrToVec2(plist["sourceSize"] as string);
            rotated = (bool)plist["rotated"];
        }
        else
        {
            frame = TPAtlas.StrToRect(plist["textureRect"] as string);
            offset = TPAtlas.StrToVec2(plist["spriteOffset"] as string);
            sourceColorRect = TPAtlas.StrToRect(plist["sourceColorRect"] as string);
            sourceSize = TPAtlas.StrToVec2(plist["spriteSourceSize"] as string);
        }
    }
}

public class TPAtlas
{
    public string realTextureFileName;
    public Vector2 size;
    public List<TPFrameData> sheets = new List<TPFrameData>();

    public void LoadX(PList plist)
    {
        //read metadata
        PList meta = plist["metadata"] as PList;
        object varCheck;
        if (meta.TryGetValue("realTextureFileName", out varCheck))
        {
            realTextureFileName = meta["realTextureFileName"] as string;
        }
        else
        {
            PList ptarget = meta["target"] as PList;
            realTextureFileName = ptarget["name"] as string;
        }

        size = StrToVec2(meta["size"] as string);

        //read frames
        PList frames = plist["frames"] as PList;
        foreach (var kv in frames)
        {
            string name = kv.Key;
            PList framedata = kv.Value as PList;
            TPFrameData frame = new TPFrameData();
            frame.LoadX(name, framedata);
            sheets.Add(frame);
        }
    }

    public static Vector2 StrToVec2(string str)
    {

        str = str.Replace("{", "");
        str = str.Replace("}", "");
        string[] vs = str.Split(',');

        Vector2 v = new Vector2();
        v.x = float.Parse(vs[0]);
        v.y = float.Parse(vs[1]);
        return v;
    }
    public static Rect StrToRect(string str)
    {
        str = str.Replace("{", "");
        str = str.Replace("}", "");
        string[] vs = str.Split(',');

        Rect v = new Rect(float.Parse(vs[0]), float.Parse(vs[1]), float.Parse(vs[2]), float.Parse(vs[3]));
        return v;
    }

}
public class SpriteSheetConvert : ScriptableObject
{
    public static string GetUTF8String(byte[] bt)
    {
        string val = System.Text.Encoding.UTF8.GetString(bt);
        return val;
    }

    static TPAtlas LoadActivePList()
    {
        Object selobj = Selection.activeObject;
        string selectionPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!selectionPath.EndsWith(".plist"))
        {
            EditorUtility.DisplayDialog("Error", "Please select a plist file!", "OK", "");
            return null;
        }

        return LoadPList(selectionPath);
    }

    static TPAtlas LoadPList(string path)
    {
        Debug.LogWarning(">> LoadPList > path = " + path);

        string fileContent = string.Empty;
        using (FileStream file = new FileStream(path, FileMode.Open))
        {
            byte[] str = new byte[(int)file.Length];
            file.Read(str, 0, str.Length);
            fileContent = GetUTF8String(str);
            Debug.Log(fileContent);
            file.Close();
            file.Dispose();
        }
        //去掉<!DOCTYPE>,不然异常
        int delStart = fileContent.IndexOf("<!DOCTYPE");
        int delEnd = fileContent.IndexOf("\n", delStart);
        fileContent = fileContent.Remove(delStart, delEnd - delStart);
        Debug.Log(fileContent);
        //解析文件
        PList plist = new PList();
        plist.LoadText(fileContent);//Load(selectionPath);
        TPAtlas at = new TPAtlas();
        at.LoadX(plist);

        return at;
    }

    static SpriteMetaData[] GetSpriteMetaData(TPAtlas at)
    {
        SpriteMetaData[] sheetMetas = new SpriteMetaData[at.sheets.Count];
        for (int i = 0; i < at.sheets.Count; i++)
        {
            TPFrameData frameData = at.sheets[i];
            sheetMetas[i].alignment = 0;
            sheetMetas[i].border = new Vector4(0, 0, 0, 0);
            sheetMetas[i].name = frameData.name;
            sheetMetas[i].pivot = new Vector2(0.5f, 0.5f);
            if (frameData.rotated)
            {
                sheetMetas[i].rect = new Rect(frameData.frame.x, at.size.y - frameData.frame.y - frameData.frame.width,
                    frameData.frame.height, frameData.frame.width);
            }
            else
            {
                sheetMetas[i].rect = new Rect(frameData.frame.x, at.size.y - frameData.frame.y - frameData.frame.height,
                    frameData.frame.width, frameData.frame.height);//这里原点在左下角，y相反
            }
            //Debug.Log("do sprite:" + frameData.name);
        }
        return sheetMetas;
    }

    [MenuItem("Assets/PList/PLis To Sprites(SelectPListFile)")]
    static void ConvertSprite()
    {
        Object selobj = Selection.activeObject;
        string selectionPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!selectionPath.EndsWith(".plist"))
        {
            EditorUtility.DisplayDialog("Error", "Please select a plist file!", "OK", "");
            return;
        }

        TPAtlas at = LoadPList(selectionPath);
        if (at == null)
        {
            return;
        }

        //重写meta
        string texPath = Path.GetDirectoryName(selectionPath) + "/" + at.realTextureFileName;
        Texture2D selTex = AssetDatabase.LoadAssetAtPath(texPath, typeof(Texture2D)) as Texture2D;
        Debug.Log(">> PLisToSprites > texture:" + texPath);
        Debug.Log(">> PLisToSprites > write texture:" + selTex.name + "  size:" + selTex.texelSize);
        TextureImporter textureImporter = AssetImporter.GetAtPath(texPath) as TextureImporter;
        if (textureImporter.textureType != TextureImporterType.Sprite && textureImporter.textureType != TextureImporterType.Default)
        {
            EditorUtility.DisplayDialog("Error", "Texture'type must be sprite or Advanced!", "OK", "");
            return;
        }
        if (textureImporter.spriteImportMode != SpriteImportMode.Multiple)
        {
            textureImporter.spriteImportMode = SpriteImportMode.Multiple;
        }
        SpriteMetaData[] sheetMetas = GetSpriteMetaData(at);
        textureImporter.spritesheet = sheetMetas;

        //save
        textureImporter.textureType = TextureImporterType.Sprite;       //bug?
        textureImporter.spriteImportMode = SpriteImportMode.Multiple;   //不加这两句会导致无法保存meta
        AssetDatabase.ImportAsset(texPath, ImportAssetOptions.ForceUpdate);

        Debug.LogWarning(">> PLisToSprites > texturePath = " + texPath);
        EditorUtility.DisplayDialog("操作完成", "PList裁分完成", "确定", "");
    }

    [MenuItem("Assets/PList/Output Sprites(SelectPListFile)")]
    static void OutputSprites()
    {
        Object selobj = Selection.activeObject;
        string selectionPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!selectionPath.EndsWith(".plist"))
        {
            EditorUtility.DisplayDialog("Error", "Please select a plist file!", "OK", "");
            return;
        }

        TPAtlas at = LoadPList(selectionPath);
        if (at == null)
        {
            return;
        }

        string texPath = Path.GetDirectoryName(selectionPath) + "/" + at.realTextureFileName;
        Texture2D selTex = AssetDatabase.LoadAssetAtPath(texPath, typeof(Texture2D)) as Texture2D;

        string rootPath = Path.GetDirectoryName(selectionPath) + "/" + Selection.activeObject.name;
        TextureImporter textureImporter = AssetImporter.GetAtPath(selectionPath) as TextureImporter;
        //textureImporter.textureType = TextureImporterType.Advanced;
        //textureImporter.isReadable = true;
        Object[] selected = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (!Directory.Exists(rootPath))
            Directory.CreateDirectory(rootPath);
        Debug.Log(">> OutputSprites > output dir :" + rootPath);

        string prefix = "pin5-";

        SpriteMetaData[] sheetMetas = GetSpriteMetaData(at);
        SpriteMetaData data;
        TPFrameData frameData;
        for (int i = 0; i < sheetMetas.Length; i++)
        {
            data = sheetMetas[i];
            frameData = at.sheets[i];
            string path = rootPath + "/" + prefix + data.name + ".png";
            string subDir = Path.GetDirectoryName(path);
            if (!Directory.Exists(subDir))
            {
                Directory.CreateDirectory(subDir);
            }
            SavePriteToPngByMeta(selTex, frameData, data, path);
        }

        AssetDatabase.Refresh();
    }

    [MenuItem("Tools/PList/UnPack Sprites")]
    static void SaveSprite()
    {
        string resourcesPath = "Assets/Resources/";
        foreach (Object obj in Selection.objects)
        {
            string selectionPath = AssetDatabase.GetAssetPath(obj);
            // 必须最上级是"Assets/Resources/"
            if (selectionPath.StartsWith(resourcesPath))
            {
                string selectionExt = System.IO.Path.GetExtension(selectionPath);
                if (selectionExt.Length == 0)
                {
                    continue;
                }
                // 从路径"Assets/Resources/UI/testUI.png"得到路径"UI/testUI"
                string loadPath = selectionPath.Remove(selectionPath.Length - selectionExt.Length);
                loadPath = loadPath.Substring(resourcesPath.Length);
                // 加载此文件下的所有资源
                Sprite[] sprites = Resources.LoadAll<Sprite>(loadPath);
                if (sprites.Length > 0)
                {
                    // 创建导出文件夹
                    string outPath = Application.dataPath + "/outSprite/" + loadPath;
                    System.IO.Directory.CreateDirectory(outPath);
                    foreach (Sprite sprite in sprites)
                    {
                        // 创建单独的纹理
                        Texture2D tex = new Texture2D((int)sprite.rect.width, (int)sprite.rect.height, sprite.texture.format, false);
                        tex.SetPixels(sprite.texture.GetPixels((int)sprite.rect.xMin, (int)sprite.rect.yMin,
                        (int)sprite.rect.width, (int)sprite.rect.height));
                        tex.Apply();
                        // 写入成PNG文件
                        System.IO.File.WriteAllBytes(outPath + "/" + sprite.name + ".png", tex.EncodeToPNG());
                    }
                    Debug.Log("SaveSprite to " + outPath);
                }
            }
        }
        Debug.Log("SaveSprite Finished");
    }

    static bool SaveSpriteToPNG(Sprite sprite, string outPath)
    {
        // 创建单独的纹理
        Texture2D tex = new Texture2D((int)sprite.rect.width, (int)sprite.rect.height, sprite.texture.format, false);
        tex.SetPixels(sprite.texture.GetPixels((int)sprite.rect.xMin, (int)sprite.rect.yMin,
        (int)sprite.rect.width, (int)sprite.rect.height));
        tex.Apply();
        // 写入成PNG文件
        File.WriteAllBytes(outPath, tex.EncodeToPNG());
        return true;
    }

    static bool SavePriteToPngByMeta(Texture2D sourceImg, TPFrameData frameData, SpriteMetaData metaData, string outPath)
    {
        Color[] pixs = sourceImg.GetPixels((int)metaData.rect.x, (int)metaData.rect.y, (int)metaData.rect.width, (int)metaData.rect.height);
        Texture2D tempTexture;
        if (frameData.rotated)
        {
            tempTexture = RotationLeft90(pixs, (int)metaData.rect.width, (int)metaData.rect.height);
        }
        else
        {
            tempTexture = new Texture2D((int)metaData.rect.width, (int)metaData.rect.height, sourceImg.format, false);
            tempTexture.SetPixels(pixs);
            tempTexture.Apply();
        }

        File.WriteAllBytes(outPath, tempTexture.EncodeToPNG());
        return true;
    }

    /// <summary>
    /// 图片逆时针旋转90度
    /// </summary>
    /// <param name="src">原图片二进制数据</param>
    /// <param name="srcW">原图片宽度</param>
    /// <param name="srcH">原图片高度</param>
    /// <param name="desTexture">输出目标图片</param>
    public static Texture2D RotationLeft90(Color[] src, int srcW, int srcH)
    {
        Color[] des = new Color[src.Length];
        Texture2D desTexture = new Texture2D(srcH, srcW);

        for (int i = 0; i < srcW; i++)
        {
            for (int j = 0; j < srcH; j++)
            {
                des[i * srcH + j] = src[(srcH - 1 - j) * srcW + i];
            }
        }

        desTexture.SetPixels(des);
        desTexture.Apply();
        return desTexture;
    }
}