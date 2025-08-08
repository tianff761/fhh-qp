using System;
using System.IO;
using UnityEngine;

public class ImageHepler
{
    public enum FormatType
    {
        PNG,
        JPG
    }

    /// <summary>
    /// 压缩图片,默认输出
    /// </summary>
    /// <param name="oPath">图片源路径</param>
    /// <param name="toPath">压缩后输出路径</param>
    /// <param name="maxPixel">最大像素值，默认1200</param>
    /// <param name="formatType">压缩后格式，默认为jpg，png会导致内存变大</param>
    /// <returns>返回是否成功</returns>
    public static bool Compress(string oPath, string toPath, float maxPixel = 1200.0f, FormatType formatType = FormatType.JPG)
    {
        try
        {
            byte[] fileData = File.ReadAllBytes(oPath);

            Texture2D tex = new Texture2D((int)(Screen.width), (int)(Screen.height), TextureFormat.RGB24, true);
            tex.LoadImage(fileData);

            float miniSize = Mathf.Max(tex.width, tex.height);

            float scale = maxPixel / miniSize;
            if (scale > 1.0f)
            {
                scale = 1.0f;
            }
            Texture2D temp = ScaleTexture(tex, (int)(tex.width * scale), (int)(tex.height * scale));

            byte[] pngData = new byte[0];
            switch (formatType)
            {
                case FormatType.PNG:
                    pngData = temp.EncodeToPNG();
                    break;
                case FormatType.JPG:
                    pngData = temp.EncodeToJPG();
                    break;
                default:
                    pngData = temp.EncodeToJPG();
                    break;
            }

            File.WriteAllBytes(toPath, pngData);
            tex = null;
            temp = null;
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
            return false;
            throw;
        }
        return true;
    }

    private static Texture2D ScaleTexture(Texture2D source, int targetWidth, int targetHeight)
    {
        Texture2D result = new Texture2D(targetWidth, targetHeight, source.format, true);
        Color[] rpixels = result.GetPixels(0);
        float incX = ((float)1 / source.width) * ((float)source.width / targetWidth);
        float incY = ((float)1 / source.height) * ((float)source.height / targetHeight);
        for (int px = 0; px < rpixels.Length; px++)
        {
            rpixels[px] = source.GetPixelBilinear(incX * ((float)px % targetWidth), incY * ((float)Mathf.Floor(px / targetWidth)));
        }
        result.SetPixels(rpixels, 0);
        result.Apply();
        return result;
    }
}
