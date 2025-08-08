using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIEffectFlowLight : MonoBehaviour {

    private float widthRate = 1;
    private float heightRate = 1;
    private float xOffsetRate = 0;
    private float yOffsetRate = 0;

    public Color color = Color.yellow;
    [Tooltip("亮度")]
    public float power = 0.55f;
    [Tooltip("移动速度")]
    public float speed = 5;
    [Tooltip("大亮条宽度")]
    public float largeWidth = 0.003f;
    [Tooltip("小亮条宽度")]
    public float littleWidth = 0.0003f;
    [Tooltip("整体长度")]
    public float length = 0.1f;
    [Tooltip("倾斜度")]
    public float skewRadio = 0.2f;//倾斜
    float moveTime = 0;
    private MaskableGraphic maskableGraphic;
    Image image;
    Material imageMat = null;

    void Awake()
    {
        Shader shader = Resources.Load("Shader/UIEffects/Flowlight") as Shader;
        maskableGraphic = GetComponent<MaskableGraphic>();
        if (maskableGraphic)
        {
            image = maskableGraphic as Image;
            if (image)
            {
                imageMat = new Material(shader);
                widthRate = image.sprite.textureRect.width * 1.0f / image.sprite.texture.width;
                heightRate = image.sprite.textureRect.height * 1.0f / image.sprite.texture.height;
                xOffsetRate = (image.sprite.textureRect.xMin) * 1.0f / image.sprite.texture.width;
                yOffsetRate = (image.sprite.textureRect.yMin) * 1.0f / image.sprite.texture.height;
            }
        }
        // Debug.Log(string.Format(" widthRate{0}, heightRate{1}， xOffsetRate{2}， yOffsetRate{3}", widthRate, heightRate, xOffsetRate, yOffsetRate));
        image.material = null;
    }

    public void OnWaitAnim()
    {
        StartCoroutine("SlowLight");
    }


    IEnumerator SlowLight()
    {
        if (image)
        {
            image.material = imageMat;
        }
        moveTime = 0;
        while (true)
        {
            moveTime += Time.deltaTime;
            SetShader();
            // Debug.Log(moveTime + ":" + endMoveTime);
            yield return null;
        }
    }

    void OnDisable()
    {
        if (image)
        {
            image.material = null;
        }
        StopCoroutine("SlowLight");
    }

    void Start()
    {
        SetShader();
        OnWaitAnim();
    }

    public void SetShader()
    {
        skewRadio = Mathf.Clamp(skewRadio, 0, 1);
        length = Mathf.Clamp(length, 0, 0.5f);
        imageMat.SetColor("_FlowlightColor", color);
        imageMat.SetFloat("_Power", power);
        imageMat.SetFloat("_MoveSpeed", speed);
        imageMat.SetFloat("_LargeWidth", largeWidth);
        imageMat.SetFloat("_LittleWidth", littleWidth);
        imageMat.SetFloat("_SkewRadio", skewRadio);
        imageMat.SetFloat("_Lengthlitandlar", length);
        imageMat.SetFloat("_MoveTime", moveTime);

        imageMat.SetFloat("_WidthRate", widthRate);
        imageMat.SetFloat("_HeightRate", heightRate);
        imageMat.SetFloat("_XOffset", xOffsetRate);
        imageMat.SetFloat("_YOffset", yOffsetRate);
    }
}
