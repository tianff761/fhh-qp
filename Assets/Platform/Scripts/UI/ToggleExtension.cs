using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ToggleExtension : MonoBehaviour {
    [Header("不可交互时显示对象")]
    public List<GameObject> notInteractableGameObject = null;

    [Header("IsOn=true显示对象")]
    public List<GameObject> selectedGameObject = null;

    [Header("IsOn=false显示对象")]
    public List<GameObject> notSelectedGameObject = null;

    [HideInInspector]
    public Toggle toggle = null;

    private void Awake()
    {
        toggle = transform.GetComponent<Toggle>();

        if (toggle != null)
        {
            SetInteractive(toggle.interactable);
            SetIsOn(toggle.isOn);
        }
    }

    void SetNotInterisOnGameObjectActive(bool active)
    {
        var len = notInteractableGameObject.Count;
        for (int i = 0; i < len; i++)
        {
            if (notInteractableGameObject[i] != null)
            {
                UIUtil.SetActive(notInteractableGameObject[i], active);
            }
        }
    }

    void SetIsOnGameObjectActive(bool active)
    {
        var len = selectedGameObject.Count;
        for (int i = 0; i < len; i++)
        {
            if (selectedGameObject[i] != null)
            {
                UIUtil.SetActive(selectedGameObject[i], active);
            }
        }
    }

    void SetIsNotOnGameObjectActive(bool active)
    {
        var len = notSelectedGameObject.Count;
        for (int i = 0; i < len; i++)
        {
            if (notSelectedGameObject[i] != null)
            {
                UIUtil.SetActive(notSelectedGameObject[i], active);
            }
        }
    }

    public void SetInteractive(bool interactive)
    {
        if (toggle == null) return;
        toggle.interactable = interactive;
        if (interactive)
        {
            SetNotInterisOnGameObjectActive(false);
            SetIsOnGameObjectActive(toggle.isOn);
            SetIsNotOnGameObjectActive(!toggle.isOn);
            if (toggle.targetGraphic != null)
            {
                UIUtil.SetActive(toggle.targetGraphic.gameObject, true);
            }
            if (toggle.graphic != null)
            {
                UIUtil.SetActive(toggle.graphic.gameObject, true);
            }
        }
        else
        {
            SetNotInterisOnGameObjectActive(true);
        }
    }

    public void SetIsOn(bool isOn)
    {
       // Debug.Log("------------------------>SetIsOn:" + name + ":" + isOn);
        if (toggle.interactable)
        {
            SetIsOnGameObjectActive(toggle.isOn);
            SetIsNotOnGameObjectActive(!toggle.isOn);
        }
        else
        {
            Debug.Log("当前组件不可交互" + name);
        }
    }
}
