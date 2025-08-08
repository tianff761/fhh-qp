using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif


public class UISpriteAtlas : MonoBehaviour
{
    /// <summary>
    /// 样板图片
    /// </summary>
    [SerializeField]
    private Sprite sampleSprite = null;

    /// <summary>
    /// 图片集合
    /// </summary>
    public Sprite[] sprites;

    private Dictionary<string, Sprite> spriteDict = new Dictionary<string, Sprite>();

    private void Awake()
    {
        spriteDict.Clear();
        if (sprites != null)
        {
            int len = sprites.Length;
            Sprite sprite = null;
            for (int i = 0; i < len; i++)
            {
                sprite = sprites[i];
                if (sprite != null)
                {
                    if (spriteDict.ContainsKey(sprite.name))
                    {
                        spriteDict[sprite.name] = sprite;
                    }
                    else 
                    {
                        spriteDict.Add(sprite.name, sprite);
                    }
                }
            }
        }
    }

    public Sprite GetSpriteByName(string spName)
    {
        if (string.IsNullOrEmpty(spName))
        {
            return null;
        }
        Sprite sp = null;
        if (spriteDict.TryGetValue(spName, out sp))
        {
            return sp;
        }
        return null;
    }

#if UNITY_EDITOR
    [ContextMenu("Load All Sprites")]
    private void LoadSprites()
    {
        if(sampleSprite == null)
        {
            Debug.LogWarning(">> sampleSprite = null.");
            return;
        }

        string path = AssetDatabase.GetAssetPath(sampleSprite);
        FileInfo fileInfo = new FileInfo(path);
        string directoryPath = fileInfo.DirectoryName.Replace("\\", "/");
        string extension = fileInfo.Extension;
        if(!extension.StartsWith("."))
        {
            extension = "." + extension;
        }

        string dataPath = Application.dataPath.Replace("\\", "/");//E:/JzdpMahjong/DpMahjongAndroid/Assets
        if(!dataPath.EndsWith("/"))
        {
            dataPath += "/";
        }
        if(!directoryPath.EndsWith("/"))
        {
            directoryPath += "/";
        }
        directoryPath = directoryPath.Replace(dataPath, "Assets/");
        Debug.LogWarning(">> LoadSprites > directoryPath = " + directoryPath);

        List<Sprite> tempSprites = new List<Sprite>();

        string[] files = Directory.GetFiles(directoryPath, "*.png");
        for(int i = 0; i < files.Length; i++)
        {
            string spritePath = files[i];
            Debug.Log(">> LoadSprites > spritePath = " + spritePath);

            Debug.Log(AssetDatabase.LoadAssetAtPath<Sprite>(spritePath));

            tempSprites.Add(AssetDatabase.LoadAssetAtPath<Sprite>(spritePath));
        }
        sprites = tempSprites.ToArray();
    }
#endif

}
