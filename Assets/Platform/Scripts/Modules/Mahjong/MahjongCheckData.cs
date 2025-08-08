using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 检测的牌数据
/// </summary>
public class MahjongCheckData
{
    /// <summary>
    /// 听用牌字典
    /// </summary>
    public static Dictionary<int, bool> TingYongCardDict = new Dictionary<int, bool>();

    /// <summary>
    /// 麻将牌的ID，如101、102等
    /// </summary>
    public int id = 0;
    /// <summary>
    /// 麻将牌的Key，如1、11、21等
    /// </summary>
    public int key = 0;
    /// <summary>
    /// 麻将类型，区分筒条万
    /// </summary>
    public int type = 0;
    /// <summary>
    /// 麻将数字，如1、2、3...
    /// </summary>
    public int num = 0;
    /// <summary>
    /// 排序字段，如果是定缺牌的话，就用ID加上一个固定值，否则就是ID
    /// </summary>
    public int sort = 0;
    /// <summary>
    /// 是否是听用
    /// </summary>
    public bool isTing = false;
    /// <summary>
    /// 用于左手牌key对象时，标记是否为根
    /// </summary>
    public bool isGang = false;
    /// <summary>
    /// 是否使用
    /// </summary>
    public bool isUse = false;

    public MahjongCheckData()
    {

    }

    //设置ID
    //101-104表示1万、201-204表示2万
    //1101-1104表示1条、1201-1204表示2条
    //2101-2104表示1同、2201-2204表示2筒
    public MahjongCheckData(int id)
    {
        this.SetId(id);
    }

    /// <summary>
    /// 动态设置ID的方法
    /// </summary>
    public void SetId(int id)
    {
        this.id = id;
        this.key = Mathf.FloorToInt(this.id / 100);
        this.type = Mathf.FloorToInt(this.id / 1000) + 1;
        this.num = this.key % 10;
        this.UpdateTingYong();
    }

    /// <summary>
    /// 更新听用
    /// </summary>
    public void UpdateTingYong() 
    {
        //处理排序
        if (TingYongCardDict.ContainsKey(this.key))
        {
            this.sort = this.id - 10000;
            this.isTing = true;
        }
        else
        {
            this.sort = this.id;
            this.isTing = false;
        }
    }
}
