using UnityEngine;
using System.IO;
using System.Runtime.InteropServices;
using System;

public class SecretHelper
{
    //解密
    unsafe public static byte[] Decode(byte[] bytes)
    {
        try
        {
            return Encryption.Decode(bytes);
        }
        catch (Exception)
        {
            Debug.LogError(" SecretHelper >>> DecryptionFile  >> 出现异常错误  > ");
            return bytes;
        }
    }
}
