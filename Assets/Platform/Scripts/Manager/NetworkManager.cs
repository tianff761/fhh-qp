using UnityEngine;
using System.Collections.Generic;
using Network;

namespace LuaFramework
{
    public class NetworkManager : Manager
    {

        private static readonly object mLockObject = new object();
        private static Queue<NetworkData> mNetworkDataQueue = new Queue<NetworkData>();
        private static Queue<SocketState> mSocketStateQueue = new Queue<SocketState>();

        private SocketClient mSocket = null;
        private NetworkData mNetworkData = null;

        void Awake()
        {
            Init();
        }

        public void Init()
        {
            if(this.mSocket == null)
            {
                this.mSocket = new SocketClient();
                this.mSocket.onReceivedData = OnReceivedData;
                this.mSocket.onSocketState = OnSocketState;
            }
        }


        /// <summary>
        /// 执行Lua方法
        /// </summary>
        public object[] CallMethod(string func, params object[] args)
        {
            return LuaUtil.CallMethod("Network", func, args);
        }

        //------------------------------------------------------------------------------------

        /// <summary>
        /// 接收数据
        /// </summary>
        private void OnReceivedData(byte[] bytes)
        {
            AddNetworkData(new NetworkData(bytes));
        }

        /// <summary>
        /// 状态
        /// </summary>
        private void OnSocketState(SocketState socketState)
        {
            mSocketStateQueue.Enqueue(socketState);
        }

        //------------------------------------------------------------------------------------

        public static void AddNetworkData(NetworkData networkData)
        {
            lock(mLockObject)
            {
                mNetworkDataQueue.Enqueue(networkData);
            }
        }

        /// <summary>
        /// 交给Command，这里不想关心发给谁。
        /// </summary>
        void Update()
        {
            if(mNetworkDataQueue.Count > 0)
            {
                while(mNetworkDataQueue.Count > 0)
                {
                    NetworkData networkData = mNetworkDataQueue.Dequeue();
                    facade.SendMessageCommand(NotiConst.DISPATCH_MESSAGE, networkData);
                }
            }

            if(mSocketStateQueue.Count > 0)
            {
                while(mSocketStateQueue.Count > 0)
                {
                    HandleSocketState(mSocketStateQueue.Dequeue());
                }
            }
        }

        /// <summary>
        /// 处理网络连接状态
        /// </summary>
        private void HandleSocketState(SocketState state)
        {
            if(state == SocketState.Connected)
            {
                Debug.Log(">> NetworkManager > OnConnected");
                LuaUtil.CallMethod("Network", "OnConnected");
            }
            else if(state == SocketState.Failed)
            {
                Debug.Log(">> NetworkManager > OnConnectFailed");
                LuaUtil.CallMethod("Network", "OnConnectFailed");
            }
            else if(state == SocketState.Closed)
            {
                Debug.Log(">> NetworkManager > OnConnectClosed");
                LuaUtil.CallMethod("Network", "OnConnectClosed");
            }
        }

        //------------------------------------------------------------------------------------

        /// <summary>
        /// 网络是否连接
        /// </summary>
        /// <returns></returns>
        public bool IsConnected()
        {
            return this.mSocket != null && this.mSocket.Connected;
        }

        /// <summary>
        /// 发送连接
        /// </summary>
        public void Connect()
        {
            if(this.mSocket == null)
            {
                Init();
            }
            Debug.Log(">> NetworkManager > Connect > 连接网络");
            this.mSocket.Connect(AppConst.SocketAddress, AppConst.SocketPort);
        }

        /// <summary>
        /// 发送SOCKET消息
        /// </summary>
        public void Send(int cmd, string json)
        {
            if(this.mSocket != null && this.mSocket.Connected)
            {
                mNetworkData = new NetworkData(cmd, json);
                this.mSocket.Send(mNetworkData.ToBytes());
            }
        }

        /// <summary>
        /// 只关闭Socket
        /// </summary>
        public void CloseSocket()
        {
            Debug.Log(">> NetworkManager > CloseSocket > 关闭网络");
            if(this.mSocket != null)
            {
                this.mSocket.Close();
            }
        }

        /// <summary>
        /// 关闭断开网络
        /// </summary>
        public void Close()
        {
            Debug.Log(">> NetworkManager > Close > 关闭网络");
            if(this.mSocket != null)
            {
                this.mSocket.Close();
            }
            this.ClearNetworkDataQueue();
            this.ClearSocketStateQueue();
        }

        /// <summary>
        /// 清除网络连接
        /// </summary>
        public void Clear()
        {
            if(this.mSocket != null)
            {
                this.mSocket.Close();
                this.mSocket.onReceivedData = null;
                this.mSocket.onSocketState = null;
                this.mSocket = null;
            }
            this.ClearNetworkDataQueue();
            this.ClearSocketStateQueue();
        }

        //------------------------------------------------------------------------------------

        /// <summary>
        /// 清除网络数据队列
        /// </summary>
        public void ClearNetworkDataQueue()
        {
            mNetworkDataQueue.Clear();
        }

        /// <summary>
        /// 清除Socket状态队列
        /// </summary>
        public void ClearSocketStateQueue()
        {
            mSocketStateQueue.Clear();
        }

        //------------------------------------------------------------------------------------

        /// <summary>
        /// 析构函数
        /// </summary>
        void OnDestroy()
        {
            this.Clear();
            Debug.Log("~NetworkManager was destroy");
        }
    }
}