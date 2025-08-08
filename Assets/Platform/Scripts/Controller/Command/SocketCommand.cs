using Network;

public class SocketCommand : ControllerCommand
{

    public override void Execute(IMessage message)
    {
        object data = message.Body;
        if(data == null) return;
        LuaUtil.CallMethod("Network", "OnSocket", (NetworkData)data);
    }

}
