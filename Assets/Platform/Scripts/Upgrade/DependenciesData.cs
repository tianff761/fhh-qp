using System.Collections.Generic;

/// <summary>
/// 依赖数据对象
/// </summary>
public class DependenciesData
{
    public DependenciesData() { }

    public Dictionary<string, DependenciesSingleData> infos = new Dictionary<string, DependenciesSingleData>();

    /// <summary>
    /// 获取AssetBundle名称的所有依赖
    /// </summary>
    public string[] GetAllDependencies(string assetBundleName)
    {
        DependenciesSingleData dependenciesSingleData = null;
        if(infos.TryGetValue(assetBundleName, out dependenciesSingleData))
        {
            return dependenciesSingleData.dependencies.ToArray();
        }
        return null;
    }
}

/// <summary>
/// 依赖单个数据对象
/// </summary>
public class DependenciesSingleData
{
    public DependenciesSingleData() { }

    private string mAssetBundleName = "";
    public List<string> dependencies = new List<string>();

    public DependenciesSingleData(string assetBundleName)
    {
        this.mAssetBundleName = assetBundleName;
        if(this.mAssetBundleName == null)
        {
            this.mAssetBundleName = "";
        }
    }

    public string assetBundleName
    {
        get { return mAssetBundleName; }
    }
}
