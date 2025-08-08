using System.IO;
using System.Text;
using System;
using LuaFramework;

namespace Network
{
    public class NetworkData
    {
        /// <summary>
        /// 命令号
        /// </summary>
        public int cmd = 0;
        /// <summary>
        /// json字符串
        /// </summary>
        public string json = string.Empty;
        /// <summary>
        /// 长度
        /// </summary>
        public int length = 0;

        MemoryStream stream = null;
        BinaryWriter writer = null;
        BinaryReader reader = null;

        /// <summary>
        /// 发送数据调用处理
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="json"></param>
        public NetworkData(int cmd, string json)
        {
            stream = new MemoryStream();
            writer = new BinaryWriter(stream);

            this.json = json;
            if(string.IsNullOrEmpty(this.json))
            {
                this.json = "{}";
            }

            try
            {
                byte[] bytes = Encoding.UTF8.GetBytes(this.json);
                writer.Write(Converter.GetBigEndian(cmd));
                writer.Write(bytes);
            }
            catch(Exception ex) { }
        }

        /// <summary>
        /// 接收数据处理
        /// </summary>
        /// <param name="length"></param>
        /// <param name="data"></param>
        public NetworkData(byte[] data)
        {
            if(data != null)
            {
                this.length = data.Length;
                stream = new MemoryStream(data);
                reader = new BinaryReader(stream);
            }
        }

        public void Close()
        {
            if(writer != null) writer.Close();
            if(reader != null) reader.Close();

            stream.Close();
            writer = null;
            reader = null;
            stream = null;
        }

        /// <summary>
        /// 解析数据，需要调用该方法后才获取数据
        /// </summary>
        public void Parse()
        {
            if(this.length > 6)
            {
                try
                {
                    this.cmd = Converter.GetBigEndian(reader.ReadInt32());
                    int bytesLength = this.length - 4;
                    byte[] bytes = new byte[bytesLength];
                    bytes = reader.ReadBytes(bytesLength);
                    this.json = Encoding.UTF8.GetString(bytes);
                }
                catch(Exception ex) { }
            }
        }

        /// <summary>
        /// 设置参数后调用该方法就可以获取到发送的二进制数据
        /// </summary>
        public byte[] ToBytes()
        {
            writer.Flush();
            return stream.ToArray();
        }

    }
}