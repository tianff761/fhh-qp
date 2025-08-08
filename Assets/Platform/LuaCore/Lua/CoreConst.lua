--C#到lua的常量定义
Util = LuaFramework.Util
LuaHelper = LuaFramework.LuaHelper
ByteBuffer = LuaFramework.ByteBuffer
AssetType = LuaFramework.AssetType

resMgr = LuaHelper.GetResManager()
panelMgr = LuaHelper.GetPanelManager()
soundMgr = LuaHelper.GetSoundManager()
networkMgr = LuaHelper.GetNetManager()

uiMgr = UIManager.Instance
--系统
DateTime = System.DateTime
--Unity引擎
Color = UnityEngine.Color
AudioSource = UnityEngine.AudioSource
AudioClip = UnityEngine.AudioClip
WWW = UnityEngine.WWW -- 可用于http请求
WWWForm = UnityEngine.WWWForm
GameObject = UnityEngine.GameObject
Input = UnityEngine.Input
SystemInfo = UnityEngine.SystemInfo -- 可用于获取设备信息等属性
PlayerPrefs = UnityEngine.PlayerPrefs -- 可用于存取本地持久化数据
Application = UnityEngine.Application -- 可用于获取部分应用信息
RuntimePlatform = UnityEngine.RuntimePlatform -- 平台枚举
ScenemMgr = UnityEngine.Screen -- 平台枚举
UnityTimes = UnityEngine.Time
Physics = UnityEngine.Physics
RectTransform = UnityEngine.RectTransform
Quaternion = UnityEngine.Quaternion
--UGUI
Canvas =  UnityEngine.UI.Canvas
Image = UnityEngine.UI.Image
Shadow = UnityEngine.UI.Shadow
Text = UnityEngine.UI.Text
Toggle = UnityEngine.UI.Toggle
ToggleGroup = UnityEngine.UI.ToggleGroup
Button = UnityEngine.UI.Button
InputField = UnityEngine.UI.InputField
Dropdown = UnityEngine.UI.Dropdown
Slider = UnityEngine.UI.Slider
TextAnchor = UnityEngine.TextAnchor
ScrollRect = UnityEngine.UI.ScrollRect
Material = UnityEngine.Material
--自定义
netImageMgr = NetImageManager.Instance
RectTransformUtility = UnityEngine.RectTransformUtility
SensitiveWordsMgr = SensitiveWordsManager.Instance
PlaybackDataMgr = PlaybackDataManager.Instance
--第三方插件
DOTween = DG.Tweening.DOTween
Ease = DG.Tweening.Ease
--类型
TypeRectTransform = typeof(RectTransform)
TypeText = typeof(Text)
TypeButton = typeof(Button)
TypeInputField = typeof(InputField)
TypeDropdown = typeof(Dropdown)
TypeImage = typeof(Image)
TypeToggle = typeof(Toggle)
TypeToggleGroup = typeof(ToggleGroup)
TypeSlider = typeof(Slider)
TypeScrollRect = typeof(ScrollRect)
TypeBoxCollider = typeof(UnityEngine.BoxCollider)
TypeAnimator = typeof(UnityEngine.Animator)
TypeCollider = typeof(UnityEngine.Collider)
TypeSkinnedMeshRenderer = typeof(UnityEngine.SkinnedMeshRenderer)
TypeCanvas = typeof(UnityEngine.Canvas)
TypeRenderer = typeof(UnityEngine.Renderer)
TypeArmature = typeof(DragonBones.UnityArmatureComponent)
TypeTweenPosition = typeof(TweenPosition)
TypeTweenRotation = typeof(TweenRotation)
TypeTweenAlpha = typeof(TweenAlpha)
TypeTweenScale = typeof(TweenScale)
TypeGridLayoutGroup = typeof(UnityEngine.UI.GridLayoutGroup)
TypeSpriteAtlas = typeof(UISpriteAtlas)
TypeSkeletonGraphic = typeof(Spine.Unity.SkeletonGraphic)
TypeWindowTweener = typeof(WindowTweener)
