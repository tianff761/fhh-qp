using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 捕鱼的路径节点
/// </summary>
public struct FishPathNode
{
    /// <summary>
    /// 该节点所在的坐标
    /// </summary>
    public Vector3 position;
    /// <summary>
    /// 该节点离上一个节点的长度
    /// </summary>
    public float length;

    public FishPathNode(Vector3 position, float length)
    {
        this.position = position;
        this.length = length;
    }
}