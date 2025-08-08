using UnityEngine;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine.UI;

public class UIInputFieldHelper : MonoBehaviour
{
    private List<string> mPatterns = new List<string>();

    private InputField mInputField = null;

    private void Awake()
    {
        mPatterns.Add(@"\p{Cs}");
        mPatterns.Add(@"[\u2702-\u27B0]");

        mInputField = this.GetComponent<InputField>();
        mInputField.onValidateInput = OnValidateInput;
    }

    /// <summary>
    /// 检测验证
    /// </summary>
    public void CheckValidate()
    {
        mInputField = this.GetComponent<InputField>();
        mInputField.onValidateInput = OnValidateInput;
    }

    /// <summary>
    /// 验证
    /// </summary>
    /// <param name="text"></param>
    /// <param name="charIndex"></param>
    /// <param name="addedChar"></param>
    /// <returns></returns>
    private char OnValidateInput(string text, int charIndex, char addedChar)
    {
        if(mPatterns.Count > 0)
        {
            string s = string.Format("{0}", addedChar);
            if(IsEmoji(s))
            {
                return '\0';
            }
        }
        return addedChar;
    }

    /// <summary>
    /// 是否是Emoji表情
    /// </summary>
    /// <param name="s"></param>
    /// <returns></returns>
    private bool IsEmoji(string s)
    {
        bool bEmoji = false;
        for(int i = 0; i < mPatterns.Count; ++i)
        {
            bEmoji = Regex.IsMatch(s, mPatterns[i]);
            if(bEmoji)
            {
                break;
            }
        }
        return bEmoji;
    }

    /// <summary>
    /// 添加验证
    /// </summary>
    /// <param name="s"></param>
    public void AddPatterns(string s)
    {
        mPatterns.Add(s);
    }

    /// <summary>
    /// 清除所有验证
    /// </summary>
    public void ClearPatterns()
    {
        mPatterns.Clear();
    }
}