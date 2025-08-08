using System;
using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif

[DisallowMultipleComponent]
public class UISpriteAnimation : MonoBehaviour
{
    /// <summary>
    /// 不设置就取当前对象上的
    /// </summary>
    public Image image;
    /// <summary>
    /// 是否循环
    /// </summary>
    public bool loop = false;
    /// <summary>
    /// OnEnable时是否重播放
    /// </summary>
    public bool isOnEnableReplay = false;
    /// <summary>
    /// 播放完成时是否自动隐藏
    /// </summary>
    public bool isAutoHide = false;
    /// <summary>
    /// 帧频
    /// </summary>
    public int fps = 30;

    //================!用于编辑器中加载Sprite使用!================
    /// <summary>
    /// 名称的前缀
    /// </summary>
    public string namePrefix = "";
    /// <summary>
    /// 名称的后缀长度
    /// </summary>
    public int nameSuffixLength = 2;
    /// <summary>
    /// 采样图片，用于定位图片
    /// </summary>
    public Sprite sampleSprite;
    /// <summary>
    /// 播放的开始索引
    /// </summary>
    public int startIndex = 0;
    /// <summary>
    /// 播放的结束索引
    /// </summary>
    public int endIndex = 1;
    //================^用于编辑器中加载Sprite使用^================

    /// <summary>
    /// 图片集合
    /// </summary>
    public Sprite[] sprites;

    /// <summary>
    /// 完成回调
    /// </summary>
    public Action<UISpriteAnimation> onCompleted = null;

    //----------------------------------------------------------------

    private bool mStarted = false;
    /// <summary>
    /// 是否可以播放
    /// </summary>
    private bool mIsCanPlay = false;
    private int mFrameIndex = 0;
    private float mInterval = 0;
    private float mTime = 0;

    private void Start()
    {
        if(image == null)
        {
            image = this.GetComponent<Image>();
        }

        if(image == null)
        {
            Debug.LogError(">> SpriteAnimation > image = null.");
            return;
        }

        if(sprites == null || sprites.Length < 1)
        {
            Debug.LogError(">> SpriteAnimation > sprites = null.");
            return;
        }

        UpdateFps();

        mStarted = true;
    }

    private void Update()
    {
        if(!mStarted || !mIsCanPlay) { return; }

        mTime += Time.deltaTime;

        if(mTime > mInterval)
        {
            mTime = 0;
            mFrameIndex++;

            if(mFrameIndex < sprites.Length)
            {
                image.sprite = sprites[mFrameIndex];
                image.SetNativeSize();
            }
            else
            {
                mFrameIndex = 0;
                if(!loop)
                {
                    this.PlayCompleted();
                }
                else
                {
                    image.sprite = sprites[mFrameIndex];
                    image.SetNativeSize();
                }
            }
        }
#if UNITY_EDITOR
        UpdateFps();
#endif

    }

    private void OnEnable()
    {
        if(isOnEnableReplay)
        {
            Replay();
        }
    }

    //================================================================

    private void UpdateFps()
    {
        if(fps < 1)
        {
            fps = 1;
        }

        mInterval = 1f / (float)fps;
    }

    //================================================================

    /// <summary>
    /// 停止播放
    /// </summary>
    public void Stop()
    {
        this.mIsCanPlay = false;
    }

    /// <summary>
    /// 播放，恢复播放
    /// </summary>
    public void Play()
    {
        this.mIsCanPlay = true;
        if(!this.gameObject.activeSelf)
        {
            this.gameObject.SetActive(true);
        }
    }

    /// <summary>
    /// 重播放，从开头播放
    /// </summary>
    public void Replay()
    {
        mFrameIndex = 0;
        mTime = 0;
        if(mStarted)
        {
            image.sprite = sprites[mFrameIndex];
            image.SetNativeSize();
        }
        this.mIsCanPlay = true;
        if(!this.gameObject.activeSelf)
        {
            this.gameObject.SetActive(true);
        }
    }

    /// <summary>
    /// 播放完成
    /// </summary>
    private void PlayCompleted()
    {
        this.mIsCanPlay = false;
        this.Stop();
        if(isAutoHide && this.gameObject.activeSelf)
        {
            this.gameObject.SetActive(false);
        }
        if(this.onCompleted != null)
        {
            this.onCompleted.Invoke(this);
        }
    }

    //================================================================

#if UNITY_EDITOR
    [ContextMenu("Load Sprites")]
    private void LoadSprites()
    {
        if(string.IsNullOrEmpty(namePrefix))
        {
            Debug.LogWarning(">> namePrefix is empty.");
            //return;
        }
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

        int length = endIndex - startIndex + 1;
        sprites = new Sprite[length];
        int index = startIndex;
        for(int i = 0; i < length; i++)
        {
            string spritePath = directoryPath + namePrefix + string.Format("{0:D" + nameSuffixLength + "}", index) + extension;
            index++;
            Debug.Log(">> LoadSprites > spritePath = " + spritePath);

            Debug.Log(AssetDatabase.LoadAssetAtPath<Sprite>(spritePath));

            sprites[i] = AssetDatabase.LoadAssetAtPath<Sprite>(spritePath);
        }

    }
#endif
}
