using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatorStateMachine : StateMachineBehaviour
{
    public Action<AnimatorStateInfo> onEnterStateCallBack;
    public Action<int> onEnterStateMachineCallBack;
    public Action<AnimatorStateInfo> onExitStateCallBack;
    public Action<int> onExitStateMachineCallBack;

    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateEnter(animator, stateInfo, layerIndex);

        if (onEnterStateCallBack != null)
        {
            onEnterStateCallBack(stateInfo);
        }
    }

    public override void OnStateMachineEnter(Animator animator, int stateMachinePathHash)
    {
        base.OnStateMachineEnter(animator, stateMachinePathHash);

        if (onEnterStateMachineCallBack != null)
        {
            onEnterStateMachineCallBack(stateMachinePathHash);
        }
    }

    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateExit(animator, stateInfo, layerIndex);

        if (onExitStateCallBack != null)
        {
            onExitStateCallBack(stateInfo);
        }
    }

    public override void OnStateMachineExit(Animator animator, int stateMachinePathHash)
    {
        base.OnStateMachineExit(animator, stateMachinePathHash);

        if (onExitStateMachineCallBack != null)
        {
            onExitStateMachineCallBack(stateMachinePathHash);
        }
    }

}
