using UnityEngine;
using ZXing;

public class QRCodeUtil
{
    /// <summary>
    /// 根据参数生成颜色数组
    /// </summary>
    public static Color32[] Generate(string contents, int width, int height, int margin)
    {
        //绘制二维码前进行一些设置
        ZXing.QrCode.QrCodeEncodingOptions options = new ZXing.QrCode.QrCodeEncodingOptions();
        //设置字符串转换格式，确保字符串信息保持正确
        options.CharacterSet = "UTF-8";
        //设置绘制区域的宽度和高度的像素值
        options.Width = width;
        options.Height = height;
        //设置二维码边缘留白宽度（值越大留白宽度大，二维码就减小）
        options.Margin = margin;

        //实例化字符串绘制二维码工具
        BarcodeWriter barcodeWriter = new BarcodeWriter { Format = BarcodeFormat.QR_CODE, Options = options };
        //进行二维码绘制并进行返回图片的颜色数组信息
        return barcodeWriter.Write(contents);
    }

    /// <summary>
    /// 根据二维码图片信息绘制指定字符串信息的二维码到指定区域
    /// </summary>
    public static Texture2D GenerateTexture(string contents, int width, int height, int margin)
    {
        //实例化一个图片类
        Texture2D texture = new Texture2D(width, height);
        //获取二维码图片颜色数组信息
        Color32[] color32 = Generate(contents, width, height, margin);
        //为图片设置绘制像素颜色信息
        texture.SetPixels32(color32);
        //设置信息更新应用下
        texture.Apply();
        //将整理好的图片信息显示到指定区域中
        return texture;
    }

    /// <summary>
    /// 开始绘制指定信息的二维码
    /// </summary>
    /// <param name="formatStr"></param>
    public static Sprite GenerateSprite(string contents, int width, int height, int margin = 1)
    {
        Texture2D texture2D = GenerateTexture(contents, width, height, margin);

        Rect spriteRect = new Rect(0, 0, texture2D.width, texture2D.height);
        Sprite sprite = Sprite.Create(texture2D, spriteRect, Vector2.zero);

        return sprite;
    }
}
