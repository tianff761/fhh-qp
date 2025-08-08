/// <summary>
/// 胡牌数据
/// </summary>
public class MahjongTingData
{
    /// <summary>
    /// 牌的Key
    /// </summary>
    public int key = 0;
    /// <summary>
    /// 番数
    /// </summary>
    public int fanNum = 0;

    public MahjongTingData(int key, int fanNum)
    {
        this.key = key;
        this.fanNum = fanNum;
    }
}
