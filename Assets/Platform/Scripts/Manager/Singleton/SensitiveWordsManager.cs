using System.Collections;
using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;
public class SensitiveWordsManager : TSingleton<SensitiveWordsManager>
{
    private SensitiveWordsManager() { }

    /// <summary>
    /// 读取到txt文本中的内容(未处理的)
    /// </summary>
    public string readText;
    Dictionary<string, string> sensitiveWords;

    /// <summary>
    /// 加载完成回调
    /// </summary>
    Action OnCallback;
    /// <summary>
    /// 读取敏感字库 传入Resources 下地址
    /// </summary>
    /// <param name="path"></param>
    public void ReadSensitiveWordsByResources(string path, Action callback)
    {
        try
        {
            OnCallback = callback;
            TextAsset textAsset = Resources.Load<TextAsset>("SensitiveWords");
            readText = textAsset.text;
            Initialize();
        }
        catch (Exception ex)
        {
            Debug.LogWarning("通过Resources读取屏蔽字库错误 " + ex.ToString());
        }
    }

    //-------------------------------前置必须调用其中一个--------------------------
    /// <summary>
    /// 通过本地url链接读取文本
    /// </summary>
    public void ReadSensitiveWordsByUrl(string url, Action callback)
    {
        try
        {
            OnCallback = callback;
            readText = File.ReadAllText(url);
            Initialize();
        }
        catch (Exception ex)
        {
            Debug.LogWarning("通过链接读取屏蔽字库错误 " + ex.ToString());
        }
    }

    /// <summary>
    /// 通过ab包以及资源名读取屏蔽字库 
    /// </summary>
    public void ReadSensitiveWordsByAssetBunld(string abName, string assetName,Action callback)
    {
        try
        {
            ResourceManager ResMgr = LuaHelper.GetResManager();
            OnCallback = callback;
            //通过ab包加载资源
            ResMgr.LoadAsset(AssetType.TEXT_ASSET, abName, assetName,(UnityEngine.Object[] objs)=> {
                try
                {
                    TextAsset ass = objs[0] as TextAsset;
                    readText = ass.text;
                    Initialize();

                    ResMgr.UnloadAssetBundle(abName, true);
                    ResMgr = null;
                }
                catch (Exception ex)
                {
                    Debug.LogWarning("通过ab包 加载完成后错误： " + ex.ToString());
                }
            });
        }
        catch (Exception ex)
        {
            Debug.LogWarning("通过ab包读取屏蔽字库错误 " + ex.ToString());
        }
    }

    /// <summary>
    /// 直接传入屏蔽字库的字（未处理（包括\n\r））
    /// </summary>
    public void ReadSensitiveWordsString(string text,Action callback)
    {
        try
        {
            OnCallback = callback;
            readText = text;
            Initialize();
        }
        catch (Exception ex)
        {
            Debug.LogWarning("通过ab包读取屏蔽字库错误 " + ex.ToString());
        }
    }

    //------------------------------------------------------
    /// <summary>
    /// 初始化敏感字库
    /// </summary>
    public void Initialize()
    {
        Debug.Log(">>>>>>>>>>>>>>>>>>>> 开始加载mingan字库");
        try
        {
            if (string.IsNullOrEmpty(readText))
            {
                Debug.Log(">>>>>>>>>>>>>>>>>>>>>> 加载失败，加载内容为空");
                return;
            }
            sensitiveWords = new Dictionary<string, string>();
            string words = readText;
            if(!string.IsNullOrEmpty(words))
            {
                string[] textwords = words.Split(new string[] { "\r\n" }, StringSplitOptions.None);
                for(int i = 0; i < textwords.Length; i++)
                {
                    if (!string.IsNullOrEmpty(textwords[i]))
                    {
                        sensitiveWords.Add(textwords[i], "");
                    }
                }
                Debug.Log(">>>>>>>>>>>>>>>>>>>>>>> mingan字库加载完成，加载数量:" + sensitiveWords.Count);
                if (OnCallback != null)
                {
                    OnCallback();
                }
            }
        }
        catch(Exception)
        {
            Debug.LogWarning(">>>>>>>>>>>>>>>> mingan字库加载错误");
            throw;
        }
    }
    /// <summary>
    /// 增加一个字库词汇
    /// </summary>
    /// <param name="word">增加的词汇</param>
    public void AddWord(string word)
    {
        if(sensitiveWords != null)
        {
            if(!sensitiveWords.ContainsKey(word))
            {
                sensitiveWords.Add(word, "");
            }
        }
        else
        {
            Debug.LogWarning(">> SensitiveWordsManager > AddWord > 字库错误");
        }
    }

    /// <summary>
    /// 移除一个词汇
    /// </summary>
    /// <param name="word">移除的词汇</param>
    public void RemoveWord(string word)
    {
        if(sensitiveWords != null)
        {
            if(sensitiveWords.ContainsKey(word))
            {
                sensitiveWords.Remove(word);
            }
        }
        else
        {
            Debug.LogWarning(">> SensitiveWordsManager > RemoveWord > 字库错误");
        }
    }

    /// <summary>
    /// 判断词汇是否存在敏感字库中
    /// </summary>
    /// <param name="word"></param>
    public Boolean CheckExistWord(string word)
    {
        if(sensitiveWords != null)
        {
            if(sensitiveWords.ContainsKey(word))
            {
                return true;
            }
        }
        else
        {
            Debug.LogWarning(">>>>>>>>>>>>>>>>> 字库错误");
        }
        return false;
    }

    /// <summary>
    /// 判断一句话中是否包含敏感字
    /// </summary>
    /// <param name="phrases"></param>
    public string CheckExistPhrases(string phrases)
    {
        if(sensitiveWords != null)
        {
            foreach(var item in sensitiveWords)
            {
                if(phrases.Contains(item.Key))
                {
                    return item.Key;
                }
            }
        }
        else
        {
            Debug.LogWarning(">>>>>>>>>>>>>>>>> 字库错误");
        }
        return string.Empty;
    }

    /// <summary>
    /// 将一句话中所有敏感字替换为某个字符
    /// </summary>
    /// <param name="phrases">短语</param>
    /// <param name="word">同于替换的词</param>
    public string ReplaceWordAtPhrases(string phrases, string word)
    {
        if(sensitiveWords != null)
        {
            foreach(var item in sensitiveWords)
            {
                if(phrases.Contains(item.Key))
                {
					int len = item.Key.Length;
					string replaceStr = "";
					for (int i = 0; i < len; i++)
					{
						replaceStr += word;
					}
                    phrases = phrases.Replace(item.Key, replaceStr);
                }
            }
            return phrases;
        }
        else
        {
            Debug.LogWarning(">>>>>>>>>>>>>>>>> 字库错误");
        }
        return phrases;
    }

}
