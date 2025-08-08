using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using LuaFramework;

namespace Network
{
    public class SocketClient
    {
        private const int MAX_READ = 8192;

        /// <summary>
        /// Socket状态变化
        /// </summary>
		public Action<SocketState> onSocketState = null;

        /// <summary>
        /// 接收数据
        /// </summary>
        public Action<byte[]> onReceivedData = null;


        private TcpClient mClient = null;
        private NetworkStream mOutStream = null;
        private MemoryStream mMemStream;
        private BinaryReader mReader;

        private byte[] mByteBuffer = new byte[MAX_READ];

        /// <summary>
        /// 服务器地址，可以是IP或者域名
        /// </summary>
        private string mHost = null;
        /// <summary>
        /// 端口
        /// </summary>
        private int mPort;
        /// <summary>
        /// Host的ID，根据时间生成的唯一ID
        /// </summary>
        private long mHostId = 0;
        /// <summary>
        /// 客户端ID，根据时间生成的唯一ID
        /// </summary>
        private long mClientId = 0;
        /// <summary>
        /// 状态
        /// </summary>
        private SocketState mSocketState = SocketState.Invalid;


        public SocketClient() { }


        public string Host
        {
            get { return this.mHost; }
        }

        public int Port
        {
            get { return this.mPort; }
        }

        public long Id
        {
            get { return this.mClientId; }
        }

        public bool Connected
        {
            get { return mClient != null && mClient.Connected; }
        }

        public void Connect(string host, int port)
        {
            if(mClient != null && this.mSocketState == SocketState.Connecting)
            {
                Debug.LogWarning(">> SocketClient > Connect > is connecting.");
                return;
            }
            //关闭TcpClient
            this.CloseTcpClient();

            Debug.Log(">> SocketClient > Connect > " + host + ":" + port);

            this.mHost = host;
            this.mPort = port;

            this.mHostId = DateTime.UtcNow.Ticks;
            Dns.BeginGetHostAddresses(this.mHost, new AsyncCallback(OnHostGot), this.mHostId);
        }

        private void OnHostGot(IAsyncResult asr)
        {
            long hostId = (long)asr.AsyncState;
            Debug.Log(">> SocketClient > OnHostGot > HostId = " + this.mHostId + ", AsyncId = " + hostId);
            if(this.mHostId != hostId)
            {
                return;
            }

            try
            {
                IPAddress[] address = Dns.EndGetHostAddresses(asr);
                if(address.Length == 0)
                {
                    Debug.LogError(">> SocketClient > OnHostGot > host invalid.");
                    return;
                }
                if(address[0].AddressFamily == AddressFamily.InterNetworkV6)
                {
                    mClient = new TcpClient(AddressFamily.InterNetworkV6);
                }
                else
                {
                    mClient = new TcpClient(AddressFamily.InterNetwork);
                }

                mClient.SendTimeout = 1000;
                mClient.ReceiveTimeout = 1000;
                mClient.NoDelay = true;

                this.mSocketState = SocketState.Connecting;
                mClientId = DateTime.UtcNow.Ticks;
                Debug.LogWarning(">> SocketClient > Id = " + this.mClientId);
                mClient.BeginConnect(address[0].ToString(), this.mPort, new AsyncCallback(OnConnect), mClientId);
            }
            catch(Exception ex)
            {
                ErrorClose();
                Debug.LogError(ex.Message);
            }
        }

        /// <summary>
        /// 连接上服务器
        /// </summary>
        private void OnConnect(IAsyncResult asr)
        {
            long id = (long)asr.AsyncState;
            Debug.Log(">> SocketClient > OnConnect > Id = " + this.mClientId + ", AsyncId = " + id);
            if(mClientId != id)
            {
                return;
            }

            if(!mClient.Connected)
            {
                this.mSocketState = SocketState.Failed;
                DispatchState(SocketState.Failed);
            }
            else
            {
                this.mSocketState = SocketState.Connected;

                this.CloseReadStream();
                mMemStream = new MemoryStream();
                mReader = new BinaryReader(mMemStream);

                mOutStream = mClient.GetStream();
                mClient.GetStream().BeginRead(mByteBuffer, 0, MAX_READ, new AsyncCallback(OnReceive), mClientId);

                DispatchState(SocketState.Connected);
            }
        }

        /// <summary>
        /// 分派状态事件
        /// </summary>
        private void DispatchState(SocketState state)
        {
            if(state == SocketState.Connected || state == SocketState.Failed || state == SocketState.Closed)
            {
                if(onSocketState != null)
                {
                    onSocketState.Invoke(state);
                }
            }
        }

        /// <summary>
        /// 关闭链接，提供外部关闭
        /// </summary>
        public void Close()
        {
            Debug.Log(">> SocketClient > Close > SocketClient > 关闭网络.");
            this.mSocketState = SocketState.Closed;
            this.CloseTcpClient();
            if(mOutStream != null)
            {
                try
                {
                    mOutStream.Close();
                }
                catch(Exception ex)
                {
                    Debug.LogException(ex);
                }
                mOutStream = null;
            }
        }

        /// <summary>
        /// 内部关闭client
        /// </summary>
        private void CloseTcpClient()
        {
            if(mClient != null)
            {
                try
                {
                    Debug.LogWarning(">> SocketClient > InternalCloseClient > Connected > Close.");
                    mClient.Close();
                }
                catch(Exception ex)
                {
                    Debug.LogException(ex);
                }
                mClient = null;
            }
        }

        /// <summary>
        /// 关闭读取流
        /// </summary>
        private void CloseReadStream()
        {
            if(mReader != null)
            {
                mReader.Close();
            }
            if(mMemStream != null)
            {
                mMemStream.Close();
            }
        }

        /// <summary>
        /// 内部错误关闭，比如链接断开
        /// </summary>
        private void ErrorClose()
        {
            Close();
            DispatchState(SocketState.Closed);
        }

        /// <summary>
        /// 发送数据
        /// </summary>
        public void Send(byte[] message)
        {
            //Debug.LogWarning(message.Length);

            if(mClient != null)
            {
                MemoryStream ms = null;
                using(ms = new MemoryStream())
                {
                    ms.Position = 0;
                    BinaryWriter writer = new BinaryWriter(ms);
                    short msgLen = (short)Converter.GetBigEndian((ushort)message.Length);
                    writer.Write(msgLen);
                    writer.Write(message);
                    writer.Flush();

                    if(mClient.Connected)
                    {
                        byte[] payload = ms.ToArray();
                        mOutStream.BeginWrite(payload, 0, payload.Length, new AsyncCallback(OnWrite), null);
                    }
                    else
                    {
                        ErrorClose();
                        Debug.LogError(">> SocketClient > Send > Connected -> false");
                    }
                }
            }
        }

        /// <summary>
        /// 向链接写入数据流
        /// </summary>
        private void OnWrite(IAsyncResult r)
        {
            try
            {
                mOutStream.EndWrite(r);
            }
            catch(Exception ex)
            {
                Debug.LogError(ex.Message);
            }
        }

        /// <summary>
        /// 接收消息
        /// </summary>
        private void OnReceive(IAsyncResult asr)
        {
            long id = (long)asr.AsyncState;
            if(mClientId != id)
            {
                Debug.Log(">> SocketClient > OnReceive > Id = " + this.mClientId + ", AsyncId = " + id);
                return;
            }

            int bytesRead = 0;
            try
            {
                lock(mClient.GetStream())
                {
                    //读取字节流到缓冲区
                    bytesRead = mClient.GetStream().EndRead(asr);

                    if(bytesRead > 0)
                    {
                        OnReceive(mByteBuffer, bytesRead);   //分析数据包内容，抛给逻辑层
                    }
                }

                if(bytesRead < 1)
                {
                    ErrorClose();
                    return;
                }

                lock(mClient.GetStream())
                {
                    //分析完，再次监听服务器发过来的新消息
                    Array.Clear(mByteBuffer, 0, mByteBuffer.Length);   //清空数组
                    mClient.GetStream().BeginRead(mByteBuffer, 0, MAX_READ, new AsyncCallback(OnReceive), mClientId);
                }
            }
            catch(Exception ex)
            {
                if(this.mSocketState != SocketState.Closed)//已经是关闭状态了，说明是主动关闭了，就不需要再分派关闭状态
                {
                    ErrorClose();
                }
                Debug.LogWarning(">> SocketClient > OnReceive > Id = " + this.mClientId);
                Debug.LogWarning(ex.Message);
            }
        }

        /// <summary>
        /// 接收到消息
        /// </summary>
        private void OnReceive(byte[] bytes, int length)
        {
            //Debug.LogWarning(">> OnReceive > 1接收数据：" + length);
            mMemStream.Seek(0, SeekOrigin.End);
            mMemStream.Write(bytes, 0, length);
            //Reset to beginning
            mMemStream.Seek(0, SeekOrigin.Begin);
            //Debug.LogWarning(">> OnReceive > 2当前数据长度：" + memStream.Length);
            //Debug.LogWarning(">> OnReceive > 3当前可读长度：" + RemainingBytes());
            while(RemainingBytes() > 2)
            {
                ushort messageLen = (ushort)mReader.ReadInt16();
                messageLen = Converter.GetBigEndian(messageLen);
                //Debug.LogWarning(">> OnReceive > 4需要读取长度：" + messageLen);
                //Debug.LogWarning(">> OnReceive > 5当前可读长度：" + RemainingBytes());
                if(RemainingBytes() >= messageLen)
                {
                    //Debug.LogWarning(">> OnReceive > 6读取数据长度：" + messageLen);
                    Debug.LogWarning(">> SocketClient > OnReceive > 读取数据长度：" + messageLen);
                    MemoryStream ms = new MemoryStream();
                    BinaryWriter writer = new BinaryWriter(ms);
                    writer.Write(mReader.ReadBytes(messageLen));
                    ms.Seek(0, SeekOrigin.Begin);
                    if(this.onReceivedData != null)
                    {
                        BinaryReader reader = new BinaryReader(ms);
                        byte[] message = reader.ReadBytes((int)(ms.Length - ms.Position));
                        this.onReceivedData.Invoke(message);
                    }
                }
                else
                {
                    mMemStream.Position = mMemStream.Position - 2;
                    break;
                }
            }
            //Debug.LogWarning(">> OnReceive > 7剩余数据长度：" + RemainingBytes());
            byte[] tempBytes = mReader.ReadBytes((int)RemainingBytes());
            mMemStream.SetLength(0);
            mMemStream.Write(tempBytes, 0, tempBytes.Length);
        }

        /// <summary>
        /// 剩余的字节
        /// </summary>
        private long RemainingBytes()
        {
            return mMemStream.Length - mMemStream.Position;
        }

        /// <summary>
        /// 销毁是调用
        /// </summary>
        public void Destroy()
        {
            Close();
            CloseReadStream();
        }

    }

}
