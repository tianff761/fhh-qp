using System.Collections.Generic;

/// <summary>
/// Md5文件数据
/// </summary>
public class Md5FilesData
{
    public Md5FilesData() { }
    public List<Md5FileSingleData> datas = new List<Md5FileSingleData>();
}

/// <summary>
/// 单个Md5文件数据
/// </summary>
public class Md5FileSingleData
{
    public string name = "";
    public string md5 = "";
    public int size = 0;
    /// <summary>
    /// 是否需要更新，运行时使用
    /// </summary>
    bool mNeedUpdate = true;

    public Md5FileSingleData() { }

    public Md5FileSingleData(string name, string md5, int size)
    {
        this.name = name;
        this.md5 = md5;
        this.size = size;
    }

    public void SetNeedUpdate(bool needUpdate)
    {
        this.mNeedUpdate = needUpdate;
    }

    public bool GetNeedUpdate()
    {
        return this.mNeedUpdate;
    }

}
