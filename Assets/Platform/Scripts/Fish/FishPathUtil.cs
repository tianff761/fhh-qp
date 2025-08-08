using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FishPathUtil
{

    public static int SmoothSens = 20;

    /// <summary>
    /// 获取线性的路径节点
    /// </summary>
    public static FishPathNode[] GetLinePathNodes(Vector3[] paths)
    {
        FishPathNode[] result = new FishPathNode[paths.Length];
        Vector3 prevPt = paths[0];
        FishPathNode moveNode = new FishPathNode(prevPt, 0);
        result[0] = moveNode;

        for(int i = 1; i < paths.Length; i++)
        {
            Vector3 currPt = paths[i];
            float distance = Vector3.Distance(prevPt, currPt);
            moveNode = new FishPathNode(currPt, distance);
            result[i] = moveNode;
            prevPt = currPt;
        }

        return result;
    }

    /// <summary>
    /// 获取曲线的路径节点
    /// </summary>
    public static FishPathNode[] GetCurcePathNodes(Vector3[] paths)
    {
        int SmoothAmount = paths.Length * SmoothSens;

        FishPathNode[] result = new FishPathNode[SmoothAmount + 1];

        Vector3[] vector3s = PathControlPointGenerator(paths);
        Vector3 prevPt = Interp(vector3s, 0);
        FishPathNode moveNode = new FishPathNode(prevPt, 0);
        result[0] = moveNode;

        for(int i = 1; i <= SmoothAmount; i++)
        {
            float pm = (float)i / SmoothAmount;
            Vector3 currPt = Interp(vector3s, pm);
            float distance = Vector3.Distance(prevPt, currPt);
            moveNode = new FishPathNode(currPt, distance);
            result[i] = moveNode;
            prevPt = currPt;
        }

        return result;
    }

    public static Vector3[] PathControlPointGenerator(Vector3[] path)
    {
        Vector3[] suppliedPath;
        Vector3[] vector3s;

        //create and store path points:
        suppliedPath = path;

        //populate calculate path;
        int offset = 2;
        vector3s = new Vector3[suppliedPath.Length + offset];
        Array.Copy(suppliedPath, 0, vector3s, 1, suppliedPath.Length);

        //populate start and end control points:
        //vector3s[0] = vector3s[1] - vector3s[2];
        vector3s[0] = vector3s[1] + (vector3s[1] - vector3s[2]);
        vector3s[vector3s.Length - 1] = vector3s[vector3s.Length - 2] + (vector3s[vector3s.Length - 2] - vector3s[vector3s.Length - 3]);

        //is this a closed, continuous loop? yes? well then so let's make a continuous Catmull-Rom spline!
        if(vector3s[1] == vector3s[vector3s.Length - 2])
        {
            Vector3[] tmpLoopSpline = new Vector3[vector3s.Length];
            Array.Copy(vector3s, tmpLoopSpline, vector3s.Length);
            tmpLoopSpline[0] = tmpLoopSpline[tmpLoopSpline.Length - 3];
            tmpLoopSpline[tmpLoopSpline.Length - 1] = tmpLoopSpline[2];
            vector3s = new Vector3[tmpLoopSpline.Length];
            Array.Copy(tmpLoopSpline, vector3s, tmpLoopSpline.Length);
        }
        return (vector3s);
    }

    public static Vector3 Interp(Vector3[] pts, float t)
    {
        int numSections = pts.Length - 3;
        int currPt = Mathf.Min(Mathf.FloorToInt(t * (float)numSections), numSections - 1);
        float u = t * (float)numSections - (float)currPt;

        Vector3 a = pts[currPt];
        Vector3 b = pts[currPt + 1];
        Vector3 c = pts[currPt + 2];
        Vector3 d = pts[currPt + 3];

        return .5f * (
            (-a + 3f * b - 3f * c + d) * (u * u * u)
            + (2f * a - 5f * b + 4f * c - d) * (u * u)
            + (-a + c) * u
            + 2f * b
        );
    }

}
