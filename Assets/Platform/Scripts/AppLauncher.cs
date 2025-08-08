using UnityEngine;
using System.Collections;

/// <summary>
/// 启动脚本，启动的唯一入口
/// </summary>
public class AppLauncher : MonoBehaviour
{
    void Awake() { }

    void Start()
    {
        StartCoroutine(OnStart());
 		UIManager.Instance.OpenInternalPanel("WelcomePanel", 1);
    }

    IEnumerator OnStart()
    {
        yield return null;
        AppManager.Instance.StartUp();
    }
}
