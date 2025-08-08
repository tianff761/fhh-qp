using UnityEngine;
using DragonBones;
using System;
public class DragonBonesUtil
{

    /// <summary>
    /// 设置播放速度(1为正常，小于0为倒放)
    /// </summary>
    public static void SetTimeScale(UnityArmatureComponent armature, float timesScale)
    {
        try
        {
            if (armature != null)
            {
                armature.animation.timeScale = timesScale;
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 播放动画
    /// </summary>
    /// <param name="armature">播放的组件</param>
    /// <param name="animName">播放的动画名称</param>
    /// <param name="playTimes">播放次数 (-1为动画默认，0为循环，1-N 为次数)</param>
    public static void Play(UnityArmatureComponent armature, string animName = null, int playTimes = -1)
    {
        try
        {
            if (armature != null)
            {
                armature.animation.Play(animName, playTimes);
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 切换骨架
    /// </summary>
    /// <param name="_armatureComponent"></param>
    /// <param name="armatureName"></param>
    /// <param name="dragonBonesName">实例名称，未设置使用默认</param>
    public static void ChangeArmatureData(UnityArmatureComponent _armatureComponent, string armatureName, string dragonBonesName = "")
    {
        bool isUGUI = _armatureComponent.isUGUI;
        UnityDragonBonesData unityData = null;
        Slot slot = null;
        if (_armatureComponent.armature != null)
        {
            unityData = _armatureComponent.unityData;
            slot = _armatureComponent.armature.parent;
            _armatureComponent.Dispose(false);

            UnityFactory.factory._dragonBones.AdvanceTime(0.0f);

            _armatureComponent.unityData = unityData;
        }

        _armatureComponent.armatureName = armatureName;
        _armatureComponent.isUGUI = isUGUI;

        _armatureComponent = UnityFactory.factory.BuildArmatureComponent(_armatureComponent.armatureName, dragonBonesName, null, _armatureComponent.unityData.dataName, _armatureComponent.gameObject, _armatureComponent.isUGUI);
        if (slot != null)
        {
            slot.childArmature = _armatureComponent.armature;
        }

        _armatureComponent.sortingLayerName = _armatureComponent.sortingLayerName;
        _armatureComponent.sortingOrder = _armatureComponent.sortingOrder;
    }

    /// <summary>
    /// 停止播放动画
    /// </summary>
    public static void Stop(UnityArmatureComponent armature)
    {
        try
        {
            if (armature != null)
            {
                armature.animation.Stop();
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 继续播放动画
    /// </summary>
    public static void UnPause(UnityArmatureComponent armature)
    {
        try
        {
            if (armature != null)
            {
                armature.animation.Play();
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 监听事件
    /// </summary>
    public static void AddEventListener(UnityArmatureComponent armature, string callbackName, Action<string, EventObject> callback)
    {
        try
        {
            if (armature != null && callbackName != null)
            {
                armature.AddDBEventListener(callbackName, (string type, EventObject obj) =>
                {
                    callback(type, obj);
                });
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 移除监听事件
    /// </summary>
    public static void RemoveEventListener(UnityArmatureComponent armature, string callbackName, ListenerDelegate<EventObject> callback)
    {
        try
        {
            if (armature != null && callbackName != null)
            {
                armature.RemoveDBEventListener(callbackName, callback);
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }
}
