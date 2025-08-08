using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

using UnityEditor;

using System;
using System.Collections.Generic;

using LuaInterface;
using LuaFramework;
using BindType = ToLuaMenu.BindType;

using Network;

public static class CustomSettings
{
    public static string FrameworkPath = AppConst.LuaFrameworkRoot;
    public static string saveDir = FrameworkPath + "/ToLua/Source/Generate/";
    public static string luaDir = FrameworkPath + "/Lua/";
    public static string toluaBaseType = FrameworkPath + "/ToLua/BaseType/";
    public static string baseLuaDir = FrameworkPath + "/ToLua/Lua";
    public static string injectionFilesPath = Application.dataPath + "/ToLua/Injection/";

    //导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
    //unity 有些类作为sealed class, 其实完全等价于静态类
    public static List<Type> staticClassTypes = new List<Type>
    {
        typeof(UnityEngine.Application),
        typeof(UnityEngine.Time),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.Input),
        typeof(UnityEngine.Resources),
        typeof(UnityEngine.Physics),
        typeof(UnityEngine.RenderSettings),
        //typeof(UnityEngine.QualitySettings),
        typeof(UnityEngine.GL),
        typeof(UnityEngine.Graphics),

    };

    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList =
    {
        _DT(typeof(Action)),
        _DT(typeof(UnityEngine.Events.UnityAction)),
        _DT(typeof(System.Predicate<int>)),
        _DT(typeof(System.Action<int>)),
        _DT(typeof(System.Comparison<int>)),
        _DT(typeof(System.Func<int, int>)),

        //add by liuxu
        _DT(typeof(System.Action<string>)),
        _DT(typeof(System.Action<float>)),
        _DT(typeof(System.Action<bool>)),
        _DT(typeof(UnityEngine.Events.UnityAction<int>)),
        _DT(typeof(UnityEngine.Events.UnityAction<string>)),
        _DT(typeof(UnityEngine.Events.UnityAction<float>)),
        _DT(typeof(UnityEngine.Events.UnityAction<bool>)),
        _DT(typeof(UnityEngine.Events.UnityAction<string, string>)),
        _DT(typeof(UnityEngine.Events.UnityAction<string, float>)),
        _DT(typeof(UnityEngine.Events.UnityAction<int, string>)),

        _DT(typeof(System.Action<int, int>)),
        _DT(typeof(System.Action<int, string>)),
        _DT(typeof(System.Action<int, float>)),
        _DT(typeof(System.Action<float, float>)),
        _DT(typeof(System.Action<GameObject>)),
        _DT(typeof(System.Action<Transform>)),

        _DT(typeof(Action<InputField.OnValidateInput>)),

        _DT(typeof(UnityEngine.Events.UnityAction<Scene, LoadSceneMode>)),
        _DT(typeof(UnityEngine.Events.UnityAction<Scene>)),
        _DT(typeof(UnityEngine.Events.UnityAction<Scene, Scene>)),
    };

    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {                
        //------------------------为例子导出--------------------------------
        //_GT(typeof(TestEventListener)),
        //_GT(typeof(TestProtol)),
        //_GT(typeof(TestAccount)),
        //_GT(typeof(Dictionary<int, TestAccount>)).SetLibName("AccountMap"),
        //_GT(typeof(KeyValuePair<int, TestAccount>)),
        //_GT(typeof(Dictionary<int, TestAccount>.KeyCollection)),
        //_GT(typeof(Dictionary<int, TestAccount>.ValueCollection)),
        //_GT(typeof(TestExport)),
        //_GT(typeof(TestExport.Space)),
        //-------------------------------------------------------------------        
                        
        _GT(typeof(UnityEngine.RuntimePlatform)),

        _GT(typeof(LuaInjectionStation)),
        _GT(typeof(InjectType)),
        _GT(typeof(Debugger)).SetNameSpace(null),

        _GT(typeof(DG.Tweening.AutoPlay)),
        _GT(typeof(DG.Tweening.AxisConstraint)),
        _GT(typeof(DG.Tweening.Ease)),
        _GT(typeof(DG.Tweening.LogBehaviour)),
        _GT(typeof(DG.Tweening.ScrambleMode)),
        _GT(typeof(DG.Tweening.TweenType)),
        _GT(typeof(DG.Tweening.UpdateType)),
        _GT(typeof(DG.Tweening.ShortcutExtensions)),
        //_GT(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(DG.Tweening.DOVirtual)),
        _GT(typeof(DG.Tweening.EaseFactory)),
        _GT(typeof(DG.Tweening.TweenParams)),
        _GT(typeof(DG.Tweening.Core.ABSSequentiable)),
        _GT(typeof(DG.Tweening.Core.TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions>)).SetWrapName ("TweenerCoreV3V3VO").SetLibName ("TweenerCoreV3V3VO"),
        _GT(typeof(DG.Tweening.DOTween)),
        _GT(typeof(DG.Tweening.Tween)).SetBaseType(typeof(System.Object)).AddExtendType(typeof(DG.Tweening.TweenExtensions)),
        _GT(typeof(DG.Tweening.Sequence)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.Tweener)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.LoopType)),
        _GT(typeof(DG.Tweening.PathMode)),
        _GT(typeof(DG.Tweening.PathType)),
        _GT(typeof(DG.Tweening.RotateMode)),

        _GT(typeof(Component)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Transform)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Light)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Material)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Rigidbody)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Camera)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(AudioSource)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),

        _GT(typeof(DelegateFactory)),
        _GT(typeof(Selectable)),
        _GT(typeof(PlayerPrefs)),
        _GT(typeof(Scene)),
        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),
        _GT(typeof(GameObject)),
        _GT(typeof(TrackedReference)),
        _GT(typeof(Application)),
        _GT(typeof(Physics)),
        _GT(typeof(Collider)),
        _GT(typeof(Collision)),
        _GT(typeof(Time)),
        _GT(typeof(Texture)),
        _GT(typeof(Texture2D)),
        _GT(typeof(Shader)),
        _GT(typeof(Renderer)),
        _GT(typeof(WWW)),
        _GT(typeof(WWWForm)),
        _GT(typeof(UnityEngine.Networking.UnityWebRequest)),
        _GT(typeof(UnityEngine.Networking.UnityWebRequestTexture)),
        _GT(typeof(UnityEngine.Networking.DownloadHandlerTexture)),
        _GT(typeof(UnityEngine.Networking.DownloadHandler)),
        _GT(typeof(UnityEngine.Networking.UnityWebRequestAsyncOperation)),

        _GT(typeof(Screen)),
        _GT(typeof(CameraClearFlags)),
        _GT(typeof(AudioClip)),
        _GT(typeof(AssetBundle)),
        //_GT(typeof(ParticleSystem)),
        _GT(typeof(AsyncOperation)).SetBaseType(typeof(System.Object)),
        _GT(typeof(LightType)),
        _GT(typeof(SleepTimeout)),
        _GT(typeof(Quaternion)),
        _GT(typeof(DeviceOrientation)),
        _GT(typeof(Touch)),

        _GT(typeof(RectTransformUtility)),

        //add by Zyh
        _GT(typeof(SystemInfo)),
        _GT(typeof(ToggleExtension)),
        _GT(typeof(ScrollRectExtension)),
        
#if UNITY_5_3_OR_NEWER && !UNITY_5_6_OR_NEWER
        _GT(typeof(UnityEngine.Experimental.Director.DirectorPlayer)),
#endif
        //动画状态机
        _GT(typeof(Animator)),
        _GT(typeof(AnimatorClipInfo)),
        _GT(typeof(AnimatorUpdateMode)),
        _GT(typeof(AnimatorControllerParameter)),
        _GT(typeof(AnimatorControllerParameterType)),
        _GT(typeof(AnimatorRecorderMode)),
        _GT(typeof(AnimatorStateInfo)),
        _GT(typeof(AnimatorStateMachine)),
        _GT(typeof(StateMachineBehaviour)),
        //-----

        _GT(typeof(Avatar)),
        _GT(typeof(Input)),
        _GT(typeof(LocationService)),
        _GT(typeof(KeyCode)),
        _GT(typeof(SkinnedMeshRenderer)),
        _GT(typeof(Space)),

        //_GT(typeof(MeshRenderer)),
#if !UNITY_5_4_OR_NEWER
        _GT(typeof(ParticleEmitter)),
        _GT(typeof(ParticleRenderer)),
        _GT(typeof(ParticleAnimator)), 
#endif

        _GT(typeof(BoxCollider)),
        _GT(typeof(MeshCollider)),
        _GT(typeof(SphereCollider)),
        _GT(typeof(CharacterController)),
        _GT(typeof(CapsuleCollider)),

        _GT(typeof(Animation)),
        _GT(typeof(AnimationClip)).SetBaseType(typeof(UnityEngine.Object)),
        _GT(typeof(AnimationState)),
        _GT(typeof(AnimationBlendMode)),
        _GT(typeof(QueueMode)),
        _GT(typeof(PlayMode)),
        _GT(typeof(WrapMode)),

        //_GT(typeof(QualitySettings)),
        _GT(typeof(RenderSettings)),
        _GT(typeof(SkinWeights)),
        _GT(typeof(RenderTexture)),
        _GT(typeof(Resources)),
        _GT(typeof(LuaProfiler)),

        //--------场景相关--------
        _GT(typeof(LoadSceneMode)),
        _GT(typeof(SceneManager)),

		//================================================================

        _GT(typeof(UIBehaviour)),
        _GT(typeof(EventSystem)),
        _GT(typeof(PointerEventData)),
        _GT(typeof(RaycastResult)),
        _GT(typeof(UnityEngine.Events.UnityEventBase)),
        _GT(typeof(UnityEngine.Events.UnityEvent)),

        _GT(typeof(Color)),
        _GT(typeof(Color32)),
        _GT(typeof(Sprite)),
        _GT(typeof(SpriteRenderer)),

        _GT(typeof(TextAnchor)),
        _GT(typeof(Graphic)),
        _GT(typeof(MaskableGraphic)),

        //Canvas
        _GT(typeof(Canvas)),
        _GT(typeof(CanvasGroup)).AddExtendType(typeof(DG.Tweening.DOTweenModuleUI)),
        _GT(typeof(RenderMode)),
        _GT(typeof(AdditionalCanvasShaderChannels)),
        _GT(typeof(CanvasScaler)),
        _GT(typeof(CanvasScaler.ScreenMatchMode)),
        _GT(typeof(CanvasScaler.ScaleMode)),
        _GT(typeof(CanvasScaler.Unit)),
        _GT(typeof(GraphicRaycaster)),
        _GT(typeof(GraphicRaycaster.BlockingObjects)),
        _GT(typeof(LayerMask)),
        _GT(typeof(SortingLayer)),
        _GT(typeof(SendMessageOptions)),

        _GT(typeof(RenderingPath)),

        //动画曲线
        _GT(typeof(Keyframe)),

        _GT(typeof(RectTransform)).AddExtendType(typeof(DG.Tweening.DOTweenModuleUI)),
        _GT(typeof(RectTransform.Edge)),
        _GT(typeof(RectTransform.Axis)),

        _GT(typeof(Button)),
        _GT(typeof(Button.ButtonClickedEvent)),
        _GT(typeof(Slider)).AddExtendType(typeof(DG.Tweening.DOTweenModuleUI)),
        _GT(typeof(Slider.SliderEvent)),

        _GT(typeof(RawImage)),
        _GT(typeof(Image)).AddExtendType(typeof(DG.Tweening.DOTweenModuleUI)),
        _GT(typeof(Text)).AddExtendType(typeof(DG.Tweening.DOTweenModuleUI)),
        _GT(typeof(Shadow)),

        _GT(typeof(InputField)),
        _GT(typeof(InputField.SubmitEvent)),
        _GT(typeof(InputField.OnChangeEvent)),
        _GT(typeof(Toggle)),
        _GT(typeof(Toggle.ToggleEvent)),
        _GT(typeof(ToggleGroup)),
        _GT(typeof(ScrollRect)),
        _GT(typeof(ScrollRect.MovementType)),
        _GT(typeof(ScrollRect.ScrollRectEvent)),
        _GT(typeof(Scrollbar)),
        _GT(typeof(Scrollbar.ScrollEvent)),
        _GT(typeof(Dropdown)),
        _GT(typeof(Dropdown.DropdownEvent)),

        _GT(typeof(Dropdown.OptionData)),
        _GT(typeof(Dropdown.OptionDataList)),

        _GT(typeof(HorizontalLayoutGroup)),
        _GT(typeof(VerticalLayoutGroup)),
        _GT(typeof(GridLayoutGroup)),
        _GT(typeof(Rect)),
        _GT(typeof(ContentSizeFitter)),
        _GT(typeof(UICircle)),

        _GT(typeof(Rigidbody2D)),
        _GT(typeof(BoxCollider2D)),
        //================================================================
        //LuaFramework

        _GT(typeof(Util)),
        _GT(typeof(AppConst)),
        _GT(typeof(LuaHelper)),
        _GT(typeof(LuaBehaviour)),

        _GT(typeof(GameManager)),
        _GT(typeof(LuaManager)),
        _GT(typeof(PanelManager)),
        _GT(typeof(SoundManager)),
        _GT(typeof(TimerManager)),
        _GT(typeof(ThreadManager)),
        _GT(typeof(NetworkManager)),
        _GT(typeof(ResourceManager)),
        _GT(typeof(NetImageManager)),
        _GT(typeof(AssetType)),

        _GT(typeof(ByteBuffer)),
        _GT(typeof(NetworkData)),

        //================================================================
        //Add By liuxu
        _GT(typeof(FileUtils)),
        _GT(typeof(LuaComponent)),

        //===============Add===Tool=====By ZYH=============
        //扑克使用的搓牌动画组件
        _GT(typeof(PokerRubCard)),
        _GT(typeof(ButtonSpeech)),
        _GT(typeof(UIWheelHelper)),
        _GT(typeof(PokerFlipCard)),

          //龙骨插件
        _GT(typeof(DragonBones.UnityArmatureComponent)),
        _GT(typeof(DragonBones.Animation)),
        _GT(typeof(DragonBones.AnimationState)),
        _GT(typeof(DragonBones.EventObject)),
        _GT(typeof(DragonBonesUtil)),

        //压缩图片
        _GT(typeof(ImageHepler)),
        _GT(typeof(ImageHepler.FormatType)),
        //================================================================
        //Custom Class

        //================================ Unity
        _GT(typeof(List<UnityEngine.GameObject>)),
        _GT(typeof(List<string>)),

        //================================ Manager 
        _GT(typeof(CoroutineManager)),
        _GT(typeof(UIManager)),

        _GT(typeof(VersionManager)),
        _GT(typeof(UpgradeManager)),
        _GT(typeof(UpgradeStatus)),
        _GT(typeof(SensitiveWordsManager)),
        _GT(typeof(PlaybackDataManager)),
        //================================ Load
        _GT(typeof(WwwLoadTask)),
        _GT(typeof(HttpLoadTask)),
        _GT(typeof(ResponseCode)),
        _GT(typeof(ResponseData)),
        _GT(typeof(HttpRequest)),
        _GT(typeof(Listener<HttpApiRequest, ResponseData>)),
        _GT(typeof(HttpApiHelper)),

        //================================ UITweener
        _GT(typeof(UITweener)).AddExtendType(typeof(Action<UITweener>)),
        _GT(typeof(TweenAlpha)),
        _GT(typeof(TweenColor)),
        _GT(typeof(TweenPosition)),
        _GT(typeof(TweenRotation)),
        _GT(typeof(TweenScale)),
        _GT(typeof(TweenSize)),
        _GT(typeof(AnimationCurve)),
        //================================ UI
        _GT(typeof(ShapeImage)),
        _GT(typeof(UIScrollViewHelper)),
        _GT(typeof(UISpriteAtlas)),
        _GT(typeof(UIToggleHelper)),
        _GT(typeof(UISpriteAnimation)).AddExtendType(typeof(Action<UISpriteAnimation>)),
        _GT(typeof(UIButtonListener)).AddExtendType(typeof(Action<UIButtonListener>)),
        _GT(typeof(UIClickFixedThroughListener)).AddExtendType(typeof(Action<UIClickFixedThroughListener, PointerEventData>)),
        _GT(typeof(UIClickListener)).AddExtendType(typeof(Action<UIClickListener>)),
        _GT(typeof(UIClickThroughListener)).AddExtendType(typeof(Action<UIClickThroughListener, PointerEventData>)),
        _GT(typeof(UIDownUpListener)).AddExtendType(typeof(Action<UIDownUpListener, PointerEventData>)),
        _GT(typeof(UIDownUpThroughListener)).AddExtendType(typeof(Action<UIDownUpThroughListener, PointerEventData>)),
        _GT(typeof(UIDragFixedThroughListener)).AddExtendType(typeof(Action<UIDragFixedThroughListener, PointerEventData>)),
        _GT(typeof(UIEventThroughListener)).AddExtendType(typeof(Action<UIEventThroughListener, PointerEventData>)),
        _GT(typeof(UIEventTriggerListener)).AddExtendType(typeof(Action<UIEventTriggerListener, PointerEventData>)),
        _GT(typeof(UIUpdateHelper)),
        _GT(typeof(UIToggleListener)).AddExtendType(typeof(Action<bool, UIToggleListener>)),
        _GT(typeof(UIAutoHideHelper)),
        _GT(typeof(Loading)),
        _GT(typeof(UIInputFieldHelper)),
        _GT(typeof(UIMenuToggleListHelper)),
        _GT(typeof(UIMenuToggleListHelper.ToggleItem)),

        //================================ Util
        _GT(typeof(TriggerHelper)),
        _GT(typeof(UIButtonHelper)),
        _GT(typeof(WindowTweener)),

        //================================ Util
        _GT(typeof(Assets)),
        _GT(typeof(UIUtil)),
        _GT(typeof(PlatformHelper)),
        _GT(typeof(GpsHelper)),
        _GT(typeof(GameObjectsHelper)),
        _GT(typeof(QRCodeUtil)),
        _GT(typeof(SafeZoneAdaptor)),

        //================================Time
        _GT(typeof(DateTime)),

        //================================捕鱼
        _GT(typeof(FishPathNode)),
        _GT(typeof(FishPathUtil)),
        //================================Mahjong
        _GT(typeof(MahjongHelper)),
        _GT(typeof(MahjongResultData)),
        _GT(typeof(MahjongTingData)),
        _GT(typeof(MahjongLeftData)),
        _GT(typeof(MahjongRuleType)),
        
        //================================ Spine
        _GT(typeof(Spine.Unity.SkeletonAnimation)),
        _GT(typeof(Spine.Unity.SkeletonGraphic)),
        _GT(typeof(Spine.Unity.SkeletonRenderer)),
        _GT(typeof(Spine.AnimationState)),
        _GT(typeof(Spine.Skeleton)),
        _GT(typeof(Spine.SkeletonData)),
        _GT(typeof(Spine.AnimationStateData)),
        _GT(typeof(Spine.TrackEntry)),
        _GT(typeof(Spine.Event)),
        _GT(typeof(Spine.EventTimeline)),
        _GT(typeof(Spine.Animation)),
        
		//=================================第三方SDK================
		//云娃
		_GT(typeof(YunWaSDK)),
        //七牛云
        _GT(typeof(QiniuApi)),
        //腾讯存储桶
        _GT(typeof(TencentBucketApi)),
    };

    public static List<Type> dynamicList = new List<Type>()
    {
        //typeof(MeshRenderer),
#if !UNITY_5_4_OR_NEWER
        typeof(ParticleEmitter),
        typeof(ParticleRenderer),
        typeof(ParticleAnimator),
#endif

        typeof(BoxCollider),
        typeof(MeshCollider),
        typeof(SphereCollider),
        typeof(CharacterController),
        typeof(CapsuleCollider),

        typeof(Animation),
        typeof(AnimationClip),
        typeof(AnimationState),

        typeof(SkinWeights),
        typeof(RenderTexture),
        typeof(Rigidbody),
    };

    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {

    };

    //ngui优化，下面的类没有派生类，可以作为sealed class
    public static List<Type> sealedList = new List<Type>()
    {

    };

    public static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    public static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }


    [MenuItem("Lua/Attach Profiler", false, 151)]
    static void AttachProfiler()
    {
        if (!Application.isPlaying)
        {
            EditorUtility.DisplayDialog("警告", "请在运行时执行此功能", "确定");
            return;
        }

        LuaClient.Instance.AttachProfiler();
    }

    [MenuItem("Lua/Detach Profiler", false, 152)]
    static void DetachProfiler()
    {
        if (!Application.isPlaying)
        {
            return;
        }

        LuaClient.Instance.DetachProfiler();
    }
}
