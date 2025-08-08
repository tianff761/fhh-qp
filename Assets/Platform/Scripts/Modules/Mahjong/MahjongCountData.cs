using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MahjongCountData
{
    /// <summary>
    /// 牌的KEY
    /// </summary>
    public int key = 0;
    /// <summary>
    /// 数据长度
    /// </summary>
    public int num = 0;
    /// <summary>
    /// 包含牌数据
    /// </summary>
    public List<MahjongCheckData> list = new List<MahjongCheckData>();
    /// <summary>
    /// 是否激活，用于标记是否在使用，因为考虑该数据对象重复使用
    /// </summary>
    public bool isActive = false;
    /// <summary>
    /// 用于统计数量
    /// </summary>
    public int count = 0;
}
