using System;
using UnityEngine;

public class UIUpdateHelper : MonoBehaviour
{

    public Action onUpdate = null;
    public Action onLateUpdate = null;

    void Update()
    {
        if(this.onUpdate != null)
        {
            this.onUpdate.Invoke();
        }
    }

    void LateUpdate()
    {
        if(this.onLateUpdate != null)
        {
            this.onLateUpdate.Invoke();
        }
    }

}
