using System.Text;
using UnityEngine;
using System.IO;

public class EncryptionHelper
{
    private const string tag = "@JZHY@";
    private const byte keyCount = 2;
    private static byte[] tagByte;
    private static int tagLen = 0;
    private static bool isInit = false;

    private static void Init()
    {
        tagByte = Encoding.UTF8.GetBytes(tag);
        for (int i = 0; i < tagByte.Length; i++)
        {
            tagByte[i] -= keyCount;
        }
        tagLen = tagByte.Length;
        isInit = true;
    }

    //解密
    public static byte[] DecryptionLua(byte[] bys, string luaFileName)
    {
        try
        {
            if (!isInit)
            {
                Init();
            }

            //判断原本文件长度是否小于需要判断加密的文件，小于表示没有加密
            if (bys.Length < tagByte.Length)
            {
                return bys;
            }
            bool isJiaMi = true;
            //判断是否是加密文件
            for (int i = 0; i < tagByte.Length; i++)
            {
                if (bys[i] != tagByte[i])
                {
                    isJiaMi = false;
                    break;
                }
            }

            byte[] newByte;
            if (isJiaMi)
            {
                int bysLen = bys.Length;
                newByte = new byte[bysLen - tagLen];
                for (int i = tagLen; i < bysLen; i++)
                {
                    newByte[i - tagLen] = (byte)(bys[i] + keyCount);
                }
            }
            else
            {
                newByte = bys;
            }
            return newByte;
        }
        catch (System.Exception)
        {
            Debug.LogError(" EncryptionHelper >>> DecryptionLua  >> 出现异常错误  > " + luaFileName);
            return bys;
        }
    }
}
