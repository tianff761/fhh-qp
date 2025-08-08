using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WelcomePanel : MonoBehaviour
{
    public Image background;
    public Transform bgArmature;

    void Start()
    {
        if (background != null)
        {
            UIUtil.SetBackgroundAdaptationByHorizontal(background);

        }
        if (bgArmature != null)
        {
            UIUtil.SetBackgroundAnimAdaptation(bgArmature, 1280, 720);
        }
    }

}