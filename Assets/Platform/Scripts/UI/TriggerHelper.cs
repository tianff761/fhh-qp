using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// 接口修改日期：20191126
/// 旧版本不实用，未使用
/// </summary>
public class TriggerHelper : MonoBehaviour
{
    public Action<GameObject> onTriggerEnter = null;
    public Action<GameObject> onTriggerExit = null;
    public Action<GameObject> onCollisionEnter = null;
    public Action<GameObject> onCollisionExit = null;

    public Action<GameObject> onTriggerEnter2d = null;
    public Action<GameObject> onTriggerExit2d = null;
    public Action<GameObject> onCollisionEnter2d = null;
    public Action<GameObject> onCollisionExit2d = null;

    private void OnTriggerEnter(Collider collider)
    {
        if (onTriggerEnter != null)
        {
            onTriggerEnter.Invoke(collider.gameObject);
        }
    }

    private void OnTriggerExit(Collider collider)
    {
        if (onTriggerExit != null)
        {
            onTriggerExit.Invoke(collider.gameObject);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (onCollisionEnter != null)
        {
            onCollisionEnter.Invoke(collision.gameObject);
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (onCollisionExit != null)
        {
            onCollisionExit.Invoke(collision.gameObject);
        }
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (onTriggerEnter2d != null)
        {
            onTriggerEnter2d.Invoke(collision.gameObject);
        }
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (onTriggerExit2d != null)
        {
            onTriggerExit2d.Invoke(collision.gameObject);
        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (onCollisionEnter2d != null)
        {
            onCollisionEnter2d.Invoke(collision.gameObject);
        }
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        if (onCollisionExit2d != null)
        {
            onCollisionExit2d.Invoke(collision.gameObject);
        }
    }
}
