using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIWheelHelper : MonoBehaviour {
    //指针
    public Transform Pointer;
    //区域数量
    public int AreaNumber = 1;

    //当区域改变时回调
    public Action<int> onAreaChange;

    //每一块区域大小
    float sizeOne = 0;


    //是否反向取值
    public bool isReverseValues = true;

    //当前区域
    public int curArea = 0;
    // Use this for initialization

    //动画曲线数组
    public AnimationCurve[] animationCurves;

    void Start () {
        sizeOne = 360 / AreaNumber;
    }
	
	// Update is called once per frame
	void Update () {
        if (Pointer != null)
        {
            float z = Pointer.localEulerAngles.z;
            if (isReverseValues)
            {
                z = 360 - z;
            }
            int x = (int)Mathf.Ceil((z + sizeOne / 2) / sizeOne);
            if (x > AreaNumber)
            {
                x = 1;
            }
            if (x != curArea)
            { 
                curArea = x;
                if (onAreaChange != null)
                {
                    onAreaChange(curArea);
                }
            }
        }
	}
}
