#if UNITY_EDITOR

using UnityEditor;

/*******************************************************************************
 * 
 *             类名: EditorConst
 *             功能: 用于存储编辑器的一些设置
 *             作者: HGQ
 *             日期:
 *             修改:
 *             
 * *****************************************************************************/

public enum EditorAssetsType
{
    /// <summary>
    /// 编辑器路径
    /// </summary>
    Editor = 0,
    /// <summary>
    /// StreamingAssets路径
    /// </summary>
    StreamingAssets = 1,
    /// <summary>
    /// 发布路径
    /// </summary>
    Release = 2,
}

public class EditorConst
{
    //================================================================


    /// <summary>
    /// 存储名称
    /// </summary>
    private const string EDITOR_ASSETS_TYPE = "EditorAssetsType";
    /// <summary>
    /// 编辑器下开发使用的资源类型
    /// </summary>
    private static EditorAssetsType mEditorAssetsType = EditorAssetsType.StreamingAssets;
    /// <summary>
    /// 是否从EditorPrefs中读取
    /// </summary>
    private static bool mIsReadEditorPrefs = false;
    /// <summary>
    /// 是否模拟发布，设置后读取资源将转到正式发布的目录下，比如使用persistentDataPath路径下
    /// </summary>
    public static EditorAssetsType editorAssetsType
    {
        get
        {
            CheckReadEditorPrefs();
            return mEditorAssetsType;
        }
        set
        {
            CheckReadEditorPrefs();
            if (value != mEditorAssetsType)
            {
                mEditorAssetsType = value;
                EditorPrefs.SetInt(EDITOR_ASSETS_TYPE, (int)mEditorAssetsType);
            }
        }
    }

    private static void CheckReadEditorPrefs()
    {
        if (!mIsReadEditorPrefs)
        {
            mIsReadEditorPrefs = true;
            mEditorAssetsType = (EditorAssetsType)EditorPrefs.GetInt(EDITOR_ASSETS_TYPE, 1);
        }
    }

    //================================================================

}

#endif