using System;
using System.Collections.Generic;
using UnityEngine;

public class MahjongHelper
{
    /// <summary>
    /// 所有牌的长度
    /// </summary>
    private static int AllCardLength = 27;
    /// <summary>
    /// 所有牌的ID
    /// </summary>
    private static int[] AllCardIds = {
        101, 201, 301, 401, 501, 601, 701, 801, 901,
        1101, 1201, 1301, 1401, 1501, 1601, 1701, 1801, 1901,
        2101, 2201, 2301, 2401, 2501, 2601, 2701, 2801, 2901
    };
    /// <summary>
    /// 所有牌的数据
    /// </summary>
    private static MahjongCheckData[] AllCardDatas = new MahjongCheckData[27];

    /// <summary>
    /// 处理3同的时候递归使用，包含了3同听
    /// </summary>
    private static List<MahjongP3Data>[] LoopP3Datas = new List<MahjongP3Data>[16];
    /// <summary>
    /// 处理3同的时候递归使用，包含了3同听
    /// </summary>
    private static List<MahjongCheckData>[] LoopSurplusCards = new List<MahjongCheckData>[16];
    /// <summary>
    /// 处理顺子听的时候递归使用（2+1）
    /// </summary>
    private static List<MahjongCheckData>[] LoopCheckNewHandLists = new List<MahjongCheckData>[16];
    /// <summary>
    /// 处理顺子听的时候递归使用（2+1）
    /// </summary>
    private static List<MahjongP3Data>[] LoopCheckNewShunZiTingList = new List<MahjongP3Data>[16];
    /// <summary>
    /// 处理单牌听的时候递归使用（1+2）
    /// </summary>
    private static List<MahjongCheckData>[] LoopNewSingleList = new List<MahjongCheckData>[16];
    /// <summary>
    /// 处理单牌听的时候递归使用（1+2）
    /// </summary>
    private static List<MahjongCheckData>[] LoopNewHandList = new List<MahjongCheckData>[16];

    /// <summary>
    /// 结果数据
    /// </summary>
    private static List<MahjongResultData> ResultList = new List<MahjongResultData>(27);

    /// <summary>
    /// Key映射字典
    /// </summary>
    private static Dictionary<int, MahjongCheckData> KeyMappingDict = new Dictionary<int, MahjongCheckData>();
    /// <summary>
    /// 是否初始化
    /// </summary>
    private static bool IsInit = false;

    /// <summary>
    /// 规则番数字典
    /// </summary>
    private static Dictionary<int, int> RuleFanNumDict = new Dictionary<int, int>();

    /// <summary>
    /// 所打的牌张总数
    /// </summary>
    private static int CardTotal = 13;
    /// <summary>
    /// 定缺类型
    /// </summary>
    private static int DingQueType = 0;
    /// <summary>
    /// 最大番数
    /// </summary>
    private static int MaxFanNum = 0;
    /// <summary>
    /// 是否检测中张
    /// </summary>
    private static bool IsCheckZhongZhang = false;
    /// <summary>
    /// 是否检测门清
    /// </summary>
    private static bool IsCheckMenQing = false;
    /// <summary>
    /// 是否检测金钩钓
    /// </summary>
    private static bool IsCheckJinGouDiao = false;
    /// <summary>
    /// 是否检测幺九
    /// </summary>
    private static bool IsCheckYaoJiu = false;
    /// <summary>
    /// 是否检测将对
    /// </summary>
    private static bool IsCheckJiangDui = false;

    /// <summary>
    /// 暗杠数量
    /// </summary>
    private static int AnGangNum = 0;
    /// <summary>
    /// 左边牌中是否存在幺鸡
    /// </summary>
    private static bool IsLeftExistYaoji = false;
    /// <summary>
    /// 左边第一个牌的类型
    /// </summary>
    private static int FirstLeftCardType = 0;
    /// <summary>
    /// 是否左边为清一色
    /// </summary>
    private static bool IsLeftQingYiSe = true;
    /// <summary>
    /// 是否左边存在1和9
    /// </summary>
    private static bool IsLeftExist19 = false;
    /// <summary>
    /// 是否左边为幺九
    /// </summary>
    private static bool IsLeftYaoJiu = false;
    /// <summary>
    /// 是否左边为将对
    /// </summary>
    private static bool IsLeftJiangDui = false;

    /// <summary>
    /// 左边的番数，主要是门清+番
    /// </summary>
    private static int LeftFanNum = 0;
    /// <summary>
    /// 基础番数，主要是金钩钓+番
    /// </summary>
    private static int BaseFanNum = 0;

    /// <summary>
    /// 左边牌数据
    /// </summary>
    private static MahjongCheckData[] LeftCards = new MahjongCheckData[4];
    /// <summary>
    /// 左边牌数据长度
    /// </summary>
    private static int LeftLength = 0;
    /// <summary>
    /// 手牌
    /// </summary>
    private static List<int> HandCards = new List<int>(16);
    /// <summary>
    /// ID所有牌的映射字典
    /// </summary>
    private static Dictionary<int, MahjongCheckData> IdAllMappingDict = new Dictionary<int, MahjongCheckData>();


    /// <summary>
    /// 手牌数据，无听用牌，无定缺牌
    /// </summary>
    private static List<MahjongCheckData> HandCardDatas = new List<MahjongCheckData>(16);
    /// <summary>
    /// 中间牌数据
    /// </summary>
    private static List<MahjongCheckData> MidCardDatas = new List<MahjongCheckData>(16);
    /// <summary>
    /// 检测过的key字典
    /// </summary>
    private static Dictionary<int, bool> CheckKeyDict = new Dictionary<int, bool>();
    /// <summary>
    /// 听牌数据列表，用于检测打牌后的听牌数据
    /// </summary>
    private static List<MahjongTingData> TingDataList = new List<MahjongTingData>(32);
    /// <summary>
    /// 检测时的手牌数据
    /// </summary>
    private static List<MahjongCheckData> CheckingHandCardDatas = new List<MahjongCheckData>(16);
    /// <summary>
    /// 手牌听用牌数量
    /// </summary>
    private static int HandTingNum = 0;
    /// <summary>
    /// --牌值统计，每一种值的牌集合，除去了听用牌
    /// </summary>
    private static MahjongCountData[] HandCountDatas = new MahjongCountData[30];
    /// <summary>
    /// 所有牌统计
    /// </summary>
    private static MahjongCountData[] AllCountDatas = new MahjongCountData[30];
    /// <summary>
    /// 算番牌统计
    /// </summary>
    private static MahjongCountData[] FanCountDatas = new MahjongCountData[30];
    /// <summary>
    /// 牌张统计List，用于后续的遍历
    /// </summary>
    private static List<MahjongCountData> HandCountList = new List<MahjongCountData>(16);
    /// <summary>
    /// 手牌的第一张牌类型
    /// </summary>
    private static int HandFirstCardType = 0;
    /// <summary>
    /// 手牌是否清一色
    /// </summary>
    private static bool IsHandQingYiSe = true;
    /// <summary>
    /// 手牌是否存在幺九
    /// </summary>
    private static bool IsHandExist19 = false;
    /// <summary>
    /// 手牌是否为幺九
    /// </summary>
    private static bool IsHandYaoJiu = false;
    /// <summary>
    /// 手牌是否为将对
    /// </summary>
    private static bool IsHandJiangDui = false;
    /// <summary>
    /// 排序
    /// </summary>
    private static Comparison<MahjongCheckData> SortComparison = null;

    /// <summary>
    /// 3同数据
    /// </summary>
    private static MahjongP3Data[] P3Datas = new MahjongP3Data[8];

    private static List<MahjongP3Data> P3List = new List<MahjongP3Data>(4);
    private static List<MahjongCheckData> SurplusCardsList = new List<MahjongCheckData>(16);
    private static List<MahjongP3Data> P3List1 = new List<MahjongP3Data>(4);
    private static List<MahjongCheckData> SurplusCardsList1 = new List<MahjongCheckData>(16);
    private static List<MahjongP3Data> P3List2 = new List<MahjongP3Data>(4);
    private static List<MahjongCheckData> SurplusCardsList2 = new List<MahjongCheckData>(16);
    private static List<MahjongP3Data> P3List3 = new List<MahjongP3Data>(4);
    private static List<MahjongCheckData> SurplusCardsList3 = new List<MahjongCheckData>(16);

    private static List<MahjongP3Data> CheckShunZiList = new List<MahjongP3Data>();
    private static List<MahjongP3Data> CheckShunZiTingList = new List<MahjongP3Data>();
    private static List<MahjongCheckData> CheckSingleList = new List<MahjongCheckData>();
    private static List<MahjongCheckData> CheckHandList = new List<MahjongCheckData>();
    /// <summary>
    /// 将对
    /// </summary>
    private static MahjongP3Data JiangDui = new MahjongP3Data();


    /// <summary>
    /// 初始化
    /// </summary>
    public static void Initialize()
    {
        if (IsInit) { return; }
        IsInit = true;
        MahjongCheckData temp = null;
        MahjongCountData temp2 = null;
        for (int i = 0; i < AllCardLength; i++)
        {
            temp = new MahjongCheckData(AllCardIds[i]);
            AllCardDatas[i] = temp;
            if (!KeyMappingDict.ContainsKey(temp.key))
            {
                KeyMappingDict.Add(temp.key, temp);
            }

            //生成手牌CountData
            temp2 = new MahjongCountData();
            temp2.key = temp.key;
            HandCountDatas[temp.key] = temp2;

            temp2 = new MahjongCountData();
            temp2.key = temp.key;
            AllCountDatas[temp.key] = temp2;

            temp2 = new MahjongCountData();
            temp2.key = temp.key;
            FanCountDatas[temp.key] = temp2;
        }
        SortComparison = new Comparison<MahjongCheckData>(SortCheckData);

        for (int i = 0; i < LeftCards.Length; i++)
        {
            LeftCards[i] = new MahjongCheckData();
        }

        for (int i = 0; i < P3Datas.Length; i++)
        {
            P3Datas[i] = new MahjongP3Data();
        }

        for (int i = 0; i < LoopP3Datas.Length; i++)
        {
            LoopP3Datas[i] = new List<MahjongP3Data>(8);
            LoopSurplusCards[i] = new List<MahjongCheckData>(16);
            LoopCheckNewHandLists[i] = new List<MahjongCheckData>(16);
            LoopCheckNewShunZiTingList[i] = new List<MahjongP3Data>(8);
            LoopNewSingleList[i] = new List<MahjongCheckData>(16);
            LoopNewHandList[i] = new List<MahjongCheckData>(16);
        }
    }


    /// <summary>
    /// 设置听用牌数据
    /// </summary>
    public static void SetTingYong(int[] tingYongs)
    {
        MahjongCheckData.TingYongCardDict.Clear();
        if (tingYongs != null)
        {
            for (int i = 0; i < tingYongs.Length; i++)
            {
                int key = tingYongs[i];
                if (!MahjongCheckData.TingYongCardDict.ContainsKey(key))
                {
                    MahjongCheckData.TingYongCardDict.Add(key, true);
                }
            }
        }
        MahjongCheckData temp = null;
        for (int i = 0; i < AllCardLength; i++)
        {
            temp = AllCardDatas[i];
            if (temp != null)
            {
                temp.UpdateTingYong();
            }
        }
        foreach (KeyValuePair<int, MahjongCheckData> kv in IdAllMappingDict)
        {
            kv.Value.UpdateTingYong();
        }
    }

    /// <summary>
    /// 设置规则
    /// </summary>
    public static void SetRules(int cardTotal, int dingQueType, int maxFan, bool isCheckZhongZhang, bool isCheckMenQing, bool isCheckJinGouDiao, bool isCheckYaoJiu, bool isCheckJiangDui)
    {
        CardTotal = cardTotal;
        DingQueType = dingQueType;
        MaxFanNum = maxFan;
        IsCheckZhongZhang = isCheckZhongZhang;
        IsCheckMenQing = isCheckMenQing;
        IsCheckJinGouDiao = isCheckJinGouDiao;
        IsCheckYaoJiu = isCheckYaoJiu;
        IsCheckJiangDui = isCheckJiangDui;
    }

    /// <summary>
    /// 清除规则番数
    /// </summary>
    public static void ClearRuleFanNum()
    {
        RuleFanNumDict.Clear();
    }

    /// <summary>
    /// 设置规则番数
    /// </summary>
    public static void SetRuleFanNum(int type, int fanNum)
    {
        if (RuleFanNumDict.ContainsKey(type))
        {
            RuleFanNumDict[type] = fanNum;
        }
        else
        {
            RuleFanNumDict.Add(type, fanNum);
        }
    }

    /// <summary>
    /// 设置规则番数
    /// </summary>
    public static void SetRuleFanNums(int[] types, int[] fanNums)
    {
        if (types != null && fanNums != null)
        {
            for (int i = 0; i < types.Length; i++)
            {
                SetRuleFanNum(types[i], fanNums[i]);
            }
        }
    }

    /// <summary>
    /// 获取规则番薯
    /// </summary>
    public static int GetRuleFanNum(int type)
    {
        int result = 0;
        if (RuleFanNumDict.TryGetValue(type, out result))
        {
            return result;
        }
        return 0;
    }

    /// <summary>
    /// 设置左边牌数据
    /// </summary>
    public static void SetLeftCards(MahjongLeftData[] leftCards)
    {
        AnGangNum = 0;
        IsLeftExistYaoji = false;
        FirstLeftCardType = 0;
        IsLeftQingYiSe = true;
        IsLeftExist19 = false;
        IsLeftYaoJiu = true;
        IsLeftJiangDui = true;
        LeftFanNum = 0;
        LeftLength = leftCards.Length;

        for (int i = 0; i < LeftCards.Length; i++)
        {
            LeftCards[i].isUse = false;
        }
        MahjongCheckData temp = null;
        MahjongLeftData leftData = null;
        for (int i = 0; i < leftCards.Length; i++)
        {
            leftData = leftCards[i];
            temp = LeftCards[i];
            temp.isUse = true;
            temp.SetId(leftData.id);
            //
            if (leftData.type == 2 || leftData.type == 3)
            {
                temp.isGang = true;
            }
            else if (leftData.type == 4)
            {
                temp.isGang = true;
                AnGangNum++;
            }
            else if (leftData.type == 15 || leftData.type == 16)
            {
                //幺鸡杠
                temp.isGang = true;
                IsLeftExistYaoji = true;
            }
            else if (leftData.type == 17)
            {
                temp.isGang = true;
                AnGangNum++;
                IsLeftExistYaoji = true;
            }
            CheckLeftQingYiSe(temp);
            if (temp.num == 1 || temp.num == 9)
            {
                IsLeftExist19 = true;
            }
            //检测幺九
            if (temp.num != 1 || temp.num != 9)
            {
                IsLeftYaoJiu = false;
            }
            //检测将对
            if (temp.num != 2 || temp.num != 5 || temp.num != 8)
            {
                IsLeftJiangDui = false;
            }
        }

        //检测门清规则
        if (IsCheckMenQing)
        {
            if (leftCards.Length == AnGangNum)
            {
                ////Debug.LogError("门清+1");
                LeftFanNum += GetRuleFanNum(MahjongRuleType.MengQing);
            }
        }
    }

    //检测左边牌是否为清一色
    private static void CheckLeftQingYiSe(MahjongCheckData cardData)
    {
        if (FirstLeftCardType == 0)
        {
            FirstLeftCardType = cardData.type;
        }
        else
        {
            if (FirstLeftCardType != cardData.type)
            {
                IsLeftQingYiSe = false;
            }
        }
    }

    /// <summary>
    /// 检测入口，传入的牌中定缺数量最多一个
    /// </summary>
    public static MahjongResultData[] Check(int[] midCards, int rightCard)
    {
        HandCards.Clear();
        HandCards.AddRange(midCards);
        if (rightCard > 0)
        {
            HandCards.Add(rightCard);
        }

        HandCardDatas.Clear();
        HandTingNum = 0;

        int length = HandCards.Count;
        MahjongCheckData temp = null;
        int id = 0;
        MahjongCheckData dingQueCardData = null;
        int dingQueCardNum = 0;
        for (int i = 0; i < length; i++)
        {
            id = HandCards[i];
            if (!IdAllMappingDict.TryGetValue(id, out temp))
            {
                temp = new MahjongCheckData(id);
                IdAllMappingDict.Add(id, temp);
            }
            temp.isUse = false;
            if (temp.isTing)
            {
                HandTingNum++;
            }
            else
            {
                if (temp.type == DingQueType)
                {
                    dingQueCardData = temp;
                    dingQueCardNum++;
                }
                else
                {
                    HandCardDatas.Add(temp);
                }
            }
        }

        //Debug.LogError("HandTingNum = " + HandTingNum);

        ResultList.Clear();

        int cardNum = LeftLength * 3 + length;
        if (dingQueCardData != null)
        {
            //Debug.LogError("cardNum = " + cardNum + " , CardTotal = " + CardTotal + " , HandTingNum = " + HandTingNum);
            //有摸牌的时，只有一个定缺牌就直接打定缺牌，否则就无法处理听牌提示
            if (cardNum > CardTotal && dingQueCardNum == 1)
            {
                //有定缺牌，直接打定缺牌
                SetMidCardDatas(HandCardDatas);//这里的手牌相当于去除定缺牌后的，所以使用默认参数-1
                MahjongResultData resultData = CheckTingDataByLoopCard(dingQueCardData.key);
                if (resultData != null)
                {
                    ResultList.Add(resultData);
                }
            }
        }
        else
        {
            CheckKeyDict.Clear();
            //大于总牌张，说明有手牌，就需要考虑打一张问题处理胡牌问题
            if (cardNum > CardTotal)
            {
                //有摸牌处理
                for (int i = 0; i < HandCardDatas.Count; i++)
                {
                    temp = HandCardDatas[i];
                    if (!CheckKeyDict.ContainsKey(temp.key))
                    {
                        CheckKeyDict.Add(temp.key, true);
                        SetMidCardDatas(HandCardDatas, i);
                        MahjongResultData resultData = CheckTingDataByLoopCard(temp.key);
                        if (resultData != null)
                        {
                            ResultList.Add(resultData);
                        }
                    }
                }
            }
            else
            {
                //无摸牌处理
                SetMidCardDatas(HandCardDatas, -1);
                MahjongResultData resultData = CheckTingDataByLoopCard(0);
                if (resultData != null)
                {
                    ResultList.Add(resultData);
                }
            }
        }

        if (ResultList.Count > 0)
        {
            return ResultList.ToArray();
        }
        else
        {
            return null;
        }
    }

    /// <summary>
    /// 设置中间牌数据
    /// </summary>
    private static void SetMidCardDatas(List<MahjongCheckData> list, int notIndex = -1)
    {
        BaseFanNum = 0;
        MidCardDatas.Clear();
        for (int i = 0; i < list.Count; i++)
        {
            if (i != notIndex)
            {
                MidCardDatas.Add(list[i]);
            }
        }
        //检测金钩钓
        if (IsCheckJinGouDiao && MidCardDatas.Count == 1)
        {
            BaseFanNum += GetRuleFanNum(MahjongRuleType.JinGouDiao);
        }
    }

    /// <summary>
    /// 获取听牌数据，key为打的牌
    /// </summary>
    private static MahjongResultData CheckTingDataByLoopCard(int key)
    {
        int count = 0;

        TingDataList.Clear();

        int tempFanNum = -1;
        MahjongCheckData temp = null;
        //遍历所有牌，为可以胡的牌
        for (int i = 0; i < AllCardLength; i++)
        {
            temp = AllCardDatas[i];
            if (!temp.isTing && temp.type != DingQueType)
            {
                //Debug.LogError(">> ========================= Play > key = " + key + ", Check = " + temp.id);

                //tempFanNum = CheckYaojiFanNumLoopCard(temp.id);//遍历方式
                tempFanNum = CheckYaojiFanNumBySingleCard(temp);
                count++;
                if (tempFanNum > -1)
                {
                    //Debug.LogError("Play > key = " + key + ", Hu = " + temp.id);
                    if (tempFanNum > MaxFanNum)
                    {
                        tempFanNum = MaxFanNum;
                    }
                    TingDataList.Add(new MahjongTingData(temp.key, tempFanNum));
                }
            }
        }

        //Debug.LogError("Play > key = " + key + ", count = " + count);

        //处理返回
        if (TingDataList.Count < 1)
        {
            return null;
        }
        else
        {
            MahjongResultData result = new MahjongResultData();
            result.key = key;
            result.list = TingDataList.ToArray();
            return result;
        }
    }

    /// <summary>
    /// 通过单张牌检测幺鸡玩法番数，需要提前设置固定数据
    /// </summary>
    private static int CheckYaojiFanNumBySingleCard(MahjongCheckData cardData)
    {
        CheckingHandCardDatas.Clear();
        CheckingHandCardDatas.AddRange(MidCardDatas);
        CheckingHandCardDatas.Add(cardData);
        CheckingHandCardDatas.Sort(SortCheckData);

        HandFirstCardType = 0;
        IsHandQingYiSe = IsLeftQingYiSe;
        IsHandExist19 = false;
        IsHandYaoJiu = true;
        IsHandJiangDui = true;
        HandCountList.Clear();
        MahjongCountData temp2 = null;
        for (int i = 0; i < HandCountDatas.Length; i++)
        {
            temp2 = HandCountDatas[i];
            if (temp2 != null)
            {
                temp2.isActive = false;
                temp2.num = 0;
                temp2.count = 0;
                temp2.list.Clear();
            }
        }
        for (int i = 0; i < CheckingHandCardDatas.Count; i++)
        {
            StatisticsSingleCard(CheckingHandCardDatas[i]);
        }

        //Debug.LogError(">>===================================key = " + cardData.key);
        int fanNum = LeftFanNum + BaseFanNum;
        //Debug.LogError("LeftFanNum+" + LeftFanNum);
        //Debug.LogError("BaseFanNum+" + BaseFanNum);
        //清一色加番
        if (IsHandQingYiSe)
        {
            //Debug.LogError("清一色+2");
            fanNum += 2;
        }
        //无鸡加番
        if (!IsLeftExistYaoji && HandTingNum == 0)
        {
            //Debug.LogError("无听用+1");
            fanNum += 1;
        }

        //处理7队
        int tempFanNum = CheckFanNumBy7Dui();
        if (tempFanNum > -1)
        {
            //Debug.LogError("七对+" + tempFanNum);
            return fanNum + tempFanNum;
        }
        //处理大对子
        tempFanNum = CheckFanNumByDaDuiZi();
        if (tempFanNum > -1)
        {
            //Debug.LogError("大对子(包括根)+" + tempFanNum);
            return fanNum + tempFanNum;
        }

        //Debug.LogError(">> HandTingNum = " + HandTingNum);

        tempFanNum = -1;
        //正常牌型处理
        if (HandTingNum == 0)
        {
            if (CheckIsHu(CheckingHandCardDatas))
            {
                tempFanNum = CheckFanNumByNoTing(CheckingHandCardDatas);
            }
        }
        else
        {
            tempFanNum = CheckFanNumByTing();
        }
        if (tempFanNum > -1)
        {
            fanNum += tempFanNum;
            return fanNum;
        }
        return -1;
    }

    /// <summary>
    /// 排序
    /// </summary>
    private static int SortCheckData(MahjongCheckData d1, MahjongCheckData d2)
    {
        return d1.sort.CompareTo(d2.sort);
    }

    /// <summary>
    /// 处理统计牌
    /// </summary>
    private static void HandleCountCards(List<MahjongCheckData> handCardDatas)
    {
        HandFirstCardType = 0;
        IsHandQingYiSe = IsLeftQingYiSe;
        IsHandExist19 = false;
        IsHandYaoJiu = true;
        IsHandJiangDui = true;
        HandCountList.Clear();
        MahjongCountData temp = null;
        for (int i = 0; i < HandCountDatas.Length; i++)
        {
            temp = HandCountDatas[i];
            if (temp != null)
            {
                temp.isActive = false;
                temp.num = 0;
                temp.count = 0;
                temp.list.Clear();
            }
        }
        for (int i = 0; i < handCardDatas.Count; i++)
        {
            StatisticsSingleCard(handCardDatas[i]);
        }
    }

    /// <summary>
    /// 统计单张牌	--万Wan = 1,条Tiao = 2,筒Tong = 3,
    /// </summary>
    private static void StatisticsSingleCard(MahjongCheckData cardData)
    {
        MahjongCountData temp = HandCountDatas[cardData.key];
        temp.isActive = true;
        temp.num++;
        temp.list.Add(cardData);
        CheckHandQingYiSe(cardData);
        if (cardData.num == 1 || cardData.num == 9)
        {
            IsHandExist19 = true;
        }
        if (IsHandJiangDui)
        {
            if (cardData.num != 2 || cardData.num != 5 || cardData.num != 8)
            {
                IsHandJiangDui = false;
            }
        }
        if (IsHandYaoJiu)
        {
            if (cardData.num > 3 && cardData.num < 7)
            {
                IsHandYaoJiu = false;
            }
        }
    }

    /// <summary>
    /// 检测清一色
    /// </summary>
    private static void CheckHandQingYiSe(MahjongCheckData cardData)
    {
        if (IsHandQingYiSe)
        {
            //有左边牌
            if (FirstLeftCardType != 0)
            {
                if (FirstLeftCardType != cardData.type)
                {
                    IsHandQingYiSe = false;
                }
            }
            else
            {
                if (HandFirstCardType == 0)
                {
                    HandFirstCardType = cardData.type;
                }
                else
                {
                    if (HandFirstCardType != cardData.type)
                    {
                        IsHandQingYiSe = false;
                    }
                }
            }
        }
    }

    /// <summary>
    /// 重置全部牌统计，用手牌覆盖
    /// </summary>
    private static void ResetAllCountDatas()
    {
        //处理统计的数据
        MahjongCountData temp1 = null;
        MahjongCountData temp2 = null;
        for (int i = 0; i < HandCountDatas.Length; i++)
        {
            temp1 = HandCountDatas[i];
            if (temp1 != null)
            {
                temp2 = AllCountDatas[i];
                temp2.isActive = temp1.isActive;
                temp2.key = temp1.key;
                temp2.num = temp1.num;
                temp2.list = temp1.list;
                temp2.count = 0;
            }
        }
    }

    /// <summary>
    /// 重置手牌统计
    /// </summary>
    private static void ResetHandCountList()
    {
        //处理统计的数据
        MahjongCountData temp1 = null;
        MahjongCountData temp2 = null;
        HandCountList.Clear();
        for (int i = 0; i < HandCountDatas.Length; i++)
        {
            temp1 = HandCountDatas[i];
            if (temp1 != null)
            {
                temp2 = AllCountDatas[i];
                temp2.isActive = temp1.isActive;
                temp2.key = temp1.key;
                temp2.num = temp1.num;
                temp2.list = temp1.list;
                temp2.count = 0;
                if (temp2.isActive)
                {
                    HandCountList.Add(temp2);
                }
            }
        }
    }

    /// <summary>
    /// 检测7对的番数，如果不是7对就返回-1，否则返回正确的番数
    /// </summary>
    private static int CheckFanNumBy7Dui()
    {
        //有左边的牌，说明就不能为7对
        if (LeftLength > 0)
        {
            return -1;
        }

        ResetHandCountList();

        //7对基础番+2
        int fanNum = 2;
        int tingNum = HandTingNum;
        int p2Num = 0;
        MahjongCountData temp = null;
        for (int i = 0; i < HandCountList.Count; i++)
        {
            temp = HandCountList[i];
            if (temp.num == 4)
            {
                fanNum++;
            }
            else if (temp.num == 3)
            {
                fanNum++;
                tingNum--;//消耗一个听子
            }
            else if (temp.num == 2)
            {
                p2Num++;
            }
            else
            {
                tingNum--;//消耗一个听子
                p2Num++;
            }
        }
        //处理2+2听用，即听子还有多，那需要把听子变成根，这样来增加最大番数
        if (tingNum > 1)
        {
            if (p2Num > 0)
            {
                p2Num--;
                tingNum -= 2;
                fanNum++;
            }
        }
        //由于最多处理2次，固代码中就写了两次
        if (tingNum > 1)
        {
            if (p2Num > 0)
            {
                p2Num--;
                tingNum -= 2;
                fanNum++;
            }
        }
        //剩余听用数量不对，说明不能成为7对
        if (tingNum < 0)
        {
            return -1;
        }
        tingNum = tingNum % 2;
        //剩余听用数量不对，不是偶数，说明不能成为7对
        if (tingNum != 0)
        {
            return -1;
        }

        //检测中张
        fanNum += CheckZhongZhang();
        //检测幺九
        fanNum += CheckYaoJiu();
        //检测将对
        fanNum += CheckJiangDui();

        return fanNum;
    }

    /// <summary>
    /// 检测中张番数
    /// </summary>
    private static int CheckZhongZhang()
    {
        if (IsCheckZhongZhang && !IsLeftExist19 && !IsHandExist19)
        {
            //Debug.LogError("中张+1");
            return GetRuleFanNum(MahjongRuleType.ZhongZhang);
        }
        return 0;
    }

    /// <summary>
    /// 检测幺九番数
    /// </summary>
    private static int CheckYaoJiu()
    {
        if (IsCheckYaoJiu && IsLeftYaoJiu && IsHandYaoJiu)
        {
            //Debug.LogError("幺九+1");
            return GetRuleFanNum(MahjongRuleType.YaoJiu);
        }
        return 0;
    }

    /// <summary>
    /// 检测将对番数
    /// </summary>
    private static int CheckJiangDui()
    {
        if (IsCheckJiangDui && IsLeftJiangDui && IsHandJiangDui)
        {
            //Debug.LogError("将对+1");
            return GetRuleFanNum(MahjongRuleType.JiangDui);
        }
        return 0;
    }

    /// <summary>
    /// 检测大对子番数
    /// </summary>
    private static int CheckFanNumByDaDuiZi()
    {
        bool isDaDuiZi = true;
        int tingNum = HandTingNum;
        int p2Num = 0;

        ResetHandCountList();

        MahjongCountData temp = null;
        for (int i = 0; i < HandCountList.Count; i++)
        {
            temp = HandCountList[i];
            if (temp.num == 4)
            {
                temp.count = 4;
                p2Num += 2;
            }
            else if (temp.num == 3)
            {
                temp.count = 3;
            }
            else if (temp.num == 2)
            {
                p2Num++;
                temp.count = 2;
            }
            else
            {
                //接把单牌使用听用设置为对子
                tingNum--;//消耗一个听子
                p2Num++;
                temp.count = 2;
            }
        }

        //是否是听用将对
        bool isTingJiangDui = false;
        //如果没有将对，则需要2个听用
        if (p2Num == 0)
        {
            isTingJiangDui = true;
            tingNum -= 2;
        }
        else
        {
            p2Num--;
        }

        //如果听用为负，说明不能组成大对子
        if (tingNum < 0 || tingNum < p2Num)
        {
            isDaDuiZi = false;
        }
        else
        {
            //需要把指定2个的对子，用听用变成3个，且手上的牌，不能出现4个的，所以不需要用听用牌处理
            for (int i = 0; i < HandCountList.Count; i++)
            {
                if (p2Num < 1)
                {
                    break;
                }

                temp = HandCountList[i];
                if (temp.count == 2)
                {
                    tingNum--;
                    temp.count = 3;
                    p2Num--;
                }
                else if (temp.count == 4)
                {
                    if (p2Num > 1)
                    {
                        tingNum -= 2;
                        temp.count = 6;
                        p2Num -= 2;
                    }
                    else if (p2Num > 0)
                    {
                        tingNum -= 1;
                        temp.count = 5;
                        p2Num -= 1;
                    }
                }
            }

            int remainder = tingNum % 3;
            if (tingNum < 0 || remainder != 0)
            {
                isDaDuiZi = false;
            }
            else
            {
                if (LeftLength > 0)
                {
                    //处理左边的牌，进行牌累加，好进行根处理
                    MahjongCheckData leftData = null;

                    for (int i = 0; i < LeftLength; i++)
                    {
                        leftData = LeftCards[i];
                        temp = AllCountDatas[leftData.key];
                        temp.isActive = true;
                        if (leftData.isGang)
                        {
                            temp.count += 4;
                        }
                        else
                        {
                            temp.count += 3;
                        }
                    }

                    HandCountList.Clear();
                    //处理统计的数据
                    for (int i = 0; i < AllCountDatas.Length; i++)
                    {
                        temp = AllCountDatas[i];
                        if (temp != null && temp.isActive)
                        {
                            HandCountList.Add(temp);
                        }
                    }
                }
                //纯听用牌，变牌
                int length = tingNum / 3;
                for (int i = 0; i < length; i++)
                {
                    for (int j = 0; j < HandCountList.Count; j++)
                    {
                        temp = HandCountList[j];
                        if (temp.count < 4)
                        {
                            temp.count += 3;
                            break;
                        }
                    }
                }
                //纯听用将对变牌，如果还有牌数为3的，就将纯听用的2个牌，变为指定的牌，来增加数量，便于统计根
                if (isTingJiangDui)
                {
                    for (int j = 0; j < HandCountList.Count; j++)
                    {
                        temp = HandCountList[j];
                        if (temp.count < 4)
                        {
                            temp.count += 2;
                            break;
                        }
                    }
                }
            }
        }

        if (isDaDuiZi)
        {
            //大对子 + 1番，根据规则来
            int fanNum = GetRuleFanNum(MahjongRuleType.DuiDuiHu);
            //
            for (int i = 0; i < HandCountList.Count; i++)
            {
                temp = HandCountList[i];
                if (temp.count > 3)
                {
                    fanNum = fanNum + 1;
                }
            }

            //检测中张
            fanNum += CheckZhongZhang();
            //检测幺九
            fanNum += CheckYaoJiu();
            //检测将对
            fanNum += CheckJiangDui();

            return fanNum;
        }
        else
        {
            return -1;
        }

    }

    /// <summary>
    /// 检测手牌是否可以胡牌，无听用，handCardDatas是已经排序好了的
    /// </summary>
    public static bool CheckIsHu(List<MahjongCheckData> handCardDatas)
    {
        //string temp33 = "";
        //for (int i = 0; i < handCardDatas.Count; i++)
        //{
        //    temp33 += "," + handCardDatas[i].key;
        //}
        //Debug.LogError(temp33);

        HandleCountCards(handCardDatas);
        ResetHandCountList();

        //检测7对是否可以胡牌
        if (LeftLength == 0)
        {
            MahjongCountData temp = null;
            bool is7Dui = true;
            for (int i = 0; i < HandCountList.Count; i++)
            {
                temp = HandCountList[i];
                if (temp.num == 1 || temp.num == 3)
                {
                    is7Dui = false;
                    break;
                }
            }
            if (is7Dui)
            {
                return true;
            }
        }

        //普通牌检测，先处理将对，然后再判断剩余的是否为三三一坎
        int length = handCardDatas.Count - 1;
        MahjongCheckData temp1 = null;
        MahjongCheckData temp2 = null;
        int lastCardKey = 0;
        for (int i = 0; i < length; i++)
        {
            temp1 = handCardDatas[i];
            //避免相同的再次检测
            if (lastCardKey != temp1.key)
            {
                lastCardKey = temp1.key;
                temp2 = handCardDatas[i + 1];
                if (temp1.key == temp2.key)
                {
                    //1、2牌一样，直接组合为将对
                    if (CheckIsHuBy3Card(temp1.key))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }



    /// <summary>
    /// 找出3同牌和其余的牌进行检测，最多为4个3同组合
    /// </summary>
    private static bool CheckIsHuBy3Card(int jiangDuiKey)
    {
        P3List.Clear();
        SurplusCardsList.Clear();

        MahjongCountData temp1 = null;
        MahjongP3Data temp2 = null;
        int index = 0;
        int len = 0;
        int tempIndex = 0;
        for (int i = 0; i < HandCountList.Count; i++)
        {
            temp1 = HandCountList[i];
            if (temp1.key == jiangDuiKey)
            {
                if (temp1.num < 2)
                {
                    return false;
                }
                tempIndex = 2;
                len = (temp1.num - 2) / 3;
            }
            else
            {
                tempIndex = 0;
                len = temp1.num / 3;
            }
            for (int j = 0; j < len; j++)
            {
                temp2 = P3Datas[index++];
                temp2.card1 = temp1.list[tempIndex++];
                temp2.card2 = temp1.list[tempIndex++];
                temp2.card3 = temp1.list[tempIndex++];
                P3List.Add(temp2);
            }

            for (int j = tempIndex; j < temp1.num; j++)
            {
                SurplusCardsList.Add(temp1.list[j]);
            }
        }

        int length = P3List.Count;
        if (length == 4)
        {
            return true;
        }
        else if (length == 3)
        {
            return CheckIsHuBy3CardLoop3(P3List, SurplusCardsList);
        }
        else if (length == 2)
        {
            return CheckIsHuBy3CardLoop2(P3List, SurplusCardsList);
        }
        else if (length == 1)
        {
            return CheckIsHuBy3CardLoop1(P3List, SurplusCardsList);
        }
        else
        {
            return CheckOnlyShunZi(SurplusCardsList);
        }
    }

    //检测是否为完整的组合牌，处理还有3个3同
    private static bool CheckIsHuBy3CardLoop3(List<MahjongP3Data> p3List, List<MahjongCheckData> surplusCardsList)
    {
        if (CheckOnlyShunZi(surplusCardsList))
        {
            return true;
        }
        //取1个三同
        MahjongP3Data temp1 = null;
        MahjongP3Data temp2 = null;
        for (int i = 0; i < p3List.Count; i++)
        {
            temp1 = p3List[i];

            P3List3.Clear();
            SurplusCardsList3.Clear();
            SurplusCardsList3.AddRange(surplusCardsList);

            for (int j = 0; j < p3List.Count; j++)
            {
                temp2 = p3List[j];

                if (i == j)
                {
                    SurplusCardsList3.Add(temp2.card1);
                    SurplusCardsList3.Add(temp2.card2);
                    SurplusCardsList3.Add(temp2.card3);
                }
                else
                {
                    P3List3.Add(temp2);
                }
            }
            if (CheckIsHuBy3CardLoop2(P3List3, SurplusCardsList3))
            {
                return true;
            }
        }
        return false;
    }

    //检测是否为完整的组合牌，处理还有2个三同
    private static bool CheckIsHuBy3CardLoop2(List<MahjongP3Data> p3List, List<MahjongCheckData> surplusCardsList)
    {
        if (CheckOnlyShunZi(surplusCardsList))
        {
            return true;
        }
        //取1个三同
        MahjongP3Data temp1 = null;
        MahjongP3Data temp2 = null;
        for (int i = 0; i < p3List.Count; i++)
        {
            temp1 = p3List[i];
            P3List2.Clear();
            SurplusCardsList2.Clear();
            SurplusCardsList2.AddRange(surplusCardsList);

            for (int j = 0; j < p3List.Count; j++)
            {
                temp2 = p3List[j];
                if (i == j)
                {
                    SurplusCardsList2.Add(temp2.card1);
                    SurplusCardsList2.Add(temp2.card2);
                    SurplusCardsList2.Add(temp2.card3);
                }
                else
                {
                    P3List2.Add(temp2);
                }
            }
            if (CheckIsHuBy3CardLoop1(P3List2, SurplusCardsList2))
            {
                return true;
            }
        }
        return false;
    }

    //检测是否为完整的组合牌，处理只有一个3同
    private static bool CheckIsHuBy3CardLoop1(List<MahjongP3Data> p3List, List<MahjongCheckData> surplusCardsList)
    {
        if (CheckOnlyShunZi(surplusCardsList))
        {
            return true;
        }
        MahjongP3Data temp2 = null;

        SurplusCardsList1.Clear();
        SurplusCardsList1.AddRange(surplusCardsList);
        temp2 = p3List[0];
        SurplusCardsList1.Add(temp2.card1);
        SurplusCardsList1.Add(temp2.card2);
        SurplusCardsList1.Add(temp2.card3);

        return CheckOnlyShunZi(SurplusCardsList1);
    }


    private static bool CheckOnlyShunZi(List<MahjongCheckData> surplusCardsList)
    {
        int length = surplusCardsList.Count;
        for (int i = 0; i < length; i++)
        {
            surplusCardsList[i].isUse = false;
        }
        surplusCardsList.Sort(SortCheckData);
        MahjongCheckData temp = null;
        MahjongCheckData temp1 = null;
        MahjongCheckData temp2 = null;
        MahjongCheckData temp3 = null;
        int key2 = 0;
        int key3 = 0;
        for (int i = 0; i < length; i++)
        {
            temp = surplusCardsList[i];
            if (!temp.isUse)
            {
                temp1 = temp;
                temp2 = null;
                temp3 = null;
                key2 = temp1.key + 1;
                key3 = temp1.key + 2;
                //找出temp2
                for (int j = 0; j < length; j++)
                {
                    temp = surplusCardsList[j];
                    if (!temp.isUse && temp.key == key2)
                    {
                        temp2 = temp;
                        break;
                    }
                }
                //找出temp3
                for (int j = 0; j < length; j++)
                {
                    temp = surplusCardsList[j];
                    if (!temp.isUse && temp.key == key3)
                    {
                        temp3 = temp;
                        break;
                    }
                }
                if (temp2 != null && temp3 != null)
                {
                    temp1.isUse = true;
                    temp2.isUse = true;
                    temp3.isUse = true;
                }
            }
        }
        for (int i = 0; i < length; i++)
        {
            temp = surplusCardsList[i];
            if (!temp.isUse)
            {
                return false;
            }
        }
        return true;
    }

    /// <summary>
    /// 检测无听用牌的番数，特殊牌型加番的处理该方法不处理
    /// </summary>
    private static int CheckFanNumByNoTing(List<MahjongCheckData> handCardDatas)
    {
        MahjongCheckData temp = null;
        MahjongCountData temp2 = null;
        for (int i = 0; i < AllCountDatas.Length; i++)
        {
            temp2 = AllCountDatas[i];
            if (temp2 != null)
            {
                temp2.count = 0;
            }
        }

        for (int i = 0; i < LeftLength; i++)
        {
            temp = LeftCards[i];
            temp2 = AllCountDatas[temp.key];

            if (temp.isGang)
            {
                temp2.count += 4;
            }
            else
            {
                temp2.count += 3;
            }
        }

        for (int i = 0; i < handCardDatas.Count; i++)
        {
            temp = handCardDatas[i];
            temp2 = AllCountDatas[temp.key];
            temp2.count += 1;
        }
        int p1Num = 0;
        int p2Num = 0;
        int p3Num = 0;
        int p4Num = 0;
        for (int i = 0; i < AllCountDatas.Length; i++)
        {
            temp2 = AllCountDatas[i];
            if (temp2 != null)
            {
                if (temp2.count == 1)
                {
                    p1Num++;
                }
                else if (temp2.count == 2)
                {
                    p2Num++;
                }
                else if (temp2.count == 3)
                {
                    p3Num++;
                }
                else if (temp2.count == 4)
                {
                    p4Num++;
                }
            }
        }
        int fanNum = p4Num;
        //检测中张
        fanNum += CheckZhongZhang();
        //检测幺九
        fanNum += CheckYaoJiu();
        //检测将对
        fanNum += CheckJiangDui();
        //检测7对加番
        if (LeftLength == 0 && p1Num == 0 && p3Num == 0)
        {
            //Debug.LogError("七对+2");
            fanNum += 2;
        }
        else
        {
            //检测大对子加番
            if (p1Num == 0 && p2Num == 1)
            {
                //Debug.LogError("大队子+" + GetRuleFanNum(MahjongRuleType.DuiDuiHu));
                fanNum += GetRuleFanNum(MahjongRuleType.DuiDuiHu);
            }
        }

        return fanNum;
    }

    /// <summary>
    /// 检测带听用的牌型番数，先遍历将对，然后把3同和2同+听的组合全部弄成3同递归
    /// </summary>
    private static int CheckFanNumByTing()
    {
        ResetHandCountList();
        //Debug.LogError(">> CheckFanNumByTing > Beigin > jiangDui loop = " + HandCountList.Count);

        int maxFanNum = -1;
        int tempFanNum = -1;
        MahjongCountData temp1 = null;
        MahjongP3Data temp2 = null;
        int tingNum = 0;
        int p3DataIndex = 0;
        //遍历将对
        for (int i = 0; i < HandCountList.Count; i++)
        {
            temp1 = HandCountList[i];

            tingNum = HandTingNum;
            P3List.Clear();
            SurplusCardsList.Clear();
            p3DataIndex = 0;

            //Debug.LogError(">> CheckFanNumByTing > JiangDui Key = " + temp1.list[0].key);

            if (temp1.num == 1)
            {
                tingNum--;
                JiangDui.card1 = temp1.list[0];
                JiangDui.card2 = temp1.list[0];
            }
            else if (temp1.num > 1)
            {
                JiangDui.card1 = temp1.list[0];
                JiangDui.card2 = temp1.list[1];

                if (temp1.num > 3)
                {
                    temp2 = P3Datas[p3DataIndex++];
                    temp2.isTing = true;
                    temp2.card1 = temp1.list[2];
                    temp2.card2 = temp1.list[3];
                    temp2.card3 = null;
                    P3List.Add(temp2);
                }
                else
                {
                    for (int j = 2; j < temp1.num; j++)
                    {
                        SurplusCardsList.Add(temp1.list[j]);
                    }
                }
            }

            for (int k = 0; k < HandCountList.Count; k++)
            {
                if (k != i)
                {
                    temp1 = HandCountList[k];
                    if (temp1.num > 2)
                    {
                        //3同以上
                        temp2 = P3Datas[p3DataIndex++];
                        temp2.isTing = false;
                        temp2.card1 = temp1.list[0];
                        temp2.card2 = temp1.list[1];
                        temp2.card3 = temp1.list[2];
                        P3List.Add(temp2);
                        for (int j = 3; j < temp1.num; j++)
                        {
                            SurplusCardsList.Add(temp1.list[j]);
                        }
                    }
                    else if (temp1.num > 1)
                    {
                        //2同
                        temp2 = P3Datas[p3DataIndex++];
                        temp2.isTing = true;
                        temp2.card1 = temp1.list[0];
                        temp2.card2 = temp1.list[1];
                        temp2.card3 = null;
                        P3List.Add(temp2);
                        tingNum--;
                    }
                    else
                    {
                        for (int j = 0; j < temp1.num; j++)
                        {
                            SurplusCardsList.Add(temp1.list[j]);
                        }
                    }
                }
            }

            //Debug.LogWarning(">> CheckMaxFanNumByTing3Card > tingNum = " + tingNum + ", p3List = " + P3List.Count + ", surplusCardsList = " + SurplusCardsList.Count);
            //string sl1 = "";
            //for (int sl = 0; sl < P3List.Count; sl++)
            //{
            //    sl1 += "," + P3List[sl].card1.key;
            //}
            //Debug.LogWarning(sl1);
            //sl1 = "";
            //for (int sl = 0; sl < SurplusCardsList.Count; sl++)
            //{
            //    sl1 += "," + SurplusCardsList[sl].key;
            //}
            //Debug.LogWarning(sl1);

            tempFanNum = CheckMaxFanNumByTing3Card(tingNum, P3List, SurplusCardsList, JiangDui);
            if (tempFanNum > maxFanNum)
            {
                maxFanNum = tempFanNum;
            }
        }

        return maxFanNum;
    }

    /// <summary>
    /// 通过处理3同（包括听用3同2+1），检测最大的番数，即算根，听用变牌，要保证能胡牌
    /// </summary>
    private static int CheckMaxFanNumByTing3Card(int tingNum, List<MahjongP3Data> p3List, List<MahjongCheckData> surplusCardsList, MahjongP3Data jiangDui)
    {
        int maxFanNum = -1;
        int tempFanNum = CheckMaxFanNumByShunZi(tingNum, p3List, surplusCardsList, jiangDui);
        if (tempFanNum > maxFanNum)
        {
            maxFanNum = tempFanNum;
        }

        int length = p3List.Count;
        int newTingNum = 0;
        MahjongP3Data temp = null;

        if (length > 0)
        {
            List<MahjongP3Data> newP3List = LoopP3Datas[length];
            List<MahjongCheckData> newSurplusCardsList = LoopSurplusCards[length];

            for (int i = 0; i < length; i++)
            {
                newP3List.Clear();
                newSurplusCardsList.Clear();
                newTingNum = tingNum;

                newSurplusCardsList.AddRange(surplusCardsList);

                temp = p3List[i];
                newSurplusCardsList.Add(temp.card1);
                newSurplusCardsList.Add(temp.card2);
                if (temp.isTing)
                {
                    newTingNum++;
                }
                else
                {
                    newSurplusCardsList.Add(temp.card3);
                }

                for (int j = 0; j < length; j++)
                {
                    if (i != j)
                    {
                        newP3List.Add(p3List[j]);
                    }
                }

                tempFanNum = CheckMaxFanNumByTing3Card(newTingNum, newP3List, newSurplusCardsList, jiangDui);
                if (tempFanNum > maxFanNum)
                {
                    maxFanNum = tempFanNum;
                }
            }
        }
        return maxFanNum;
    }

    /// <summary>
    /// 把单牌进行组合检测
    /// </summary>
    private static int CheckMaxFanNumByShunZi(int tingNum, List<MahjongP3Data> p3List, List<MahjongCheckData> surplusCardsList, MahjongP3Data jiangDui)
    {
        int maxFanNum = -1;
        if (tingNum < 0)
        {
            //听牌数量不够
            return maxFanNum;
        }
        CheckShunZiList.Clear();
        CheckShunZiTingList.Clear();
        CheckSingleList.Clear();
        CheckOnlyShunZiByTing(CheckShunZiList, CheckShunZiTingList, CheckSingleList, surplusCardsList);
        if ((CheckShunZiTingList.Count + CheckSingleList.Count * 2) != tingNum)
        {
            //听牌数量不够
            return maxFanNum;
        }
        CheckHandList.Clear();
        MahjongP3Data temp = null;
        //-添加非听用3同
        for (int i = 0; i < p3List.Count; i++)
        {
            temp = p3List[i];
            CheckHandList.Add(temp.card1);
            CheckHandList.Add(temp.card2);
            if (temp.isTing)
            {
                CheckHandList.Add(temp.card1);
            }
            else
            {
                CheckHandList.Add(temp.card3);
            }
        }
        //添加将对
        CheckHandList.Add(jiangDui.card1);
        CheckHandList.Add(jiangDui.card1);
        //添加非听用顺子
        for (int i = 0; i < CheckShunZiList.Count; i++)
        {
            temp = CheckShunZiList[i];
            CheckHandList.Add(temp.card1);
            CheckHandList.Add(temp.card2);
            CheckHandList.Add(temp.card3);
        }
        maxFanNum = CheckMaxFanNumByShunZiTing(CheckHandList, CheckShunZiTingList, CheckSingleList);
        return maxFanNum;
    }

    /// <summary>
    /// 只检测3个顺子和2个牌+听用的顺子组合，不处理2个的对牌
    /// </summary>
    private static void CheckOnlyShunZiByTing(List<MahjongP3Data> shunZiList, List<MahjongP3Data> shunZiTingList, List<MahjongCheckData> singleList, List<MahjongCheckData> surplusCardsList)
    {
        for (int i = 0; i < surplusCardsList.Count; i++)
        {
            surplusCardsList[i].isUse = false;
        }
        surplusCardsList.Sort(SortComparison);
        MahjongCheckData tempCard = null;
        MahjongCheckData temp1 = null;
        MahjongCheckData temp2 = null;
        MahjongCheckData temp3 = null;
        MahjongP3Data temp = null;
        int key2 = 0;
        int key3 = 0;
        for (int i = 0; i < surplusCardsList.Count; i++)
        {
            tempCard = surplusCardsList[i];
            if (!tempCard.isUse)
            {
                temp1 = tempCard;
                temp2 = null;
                temp3 = null;
                key2 = temp1.key + 1;
                key3 = temp1.key + 2;
                for (int j = i + 1; j < surplusCardsList.Count; j++)
                {
                    tempCard = surplusCardsList[j];
                    if (!tempCard.isUse && tempCard.key == key2)
                    {
                        temp2 = tempCard;
                        break;
                    }
                }
                for (int j = i + 1; j < surplusCardsList.Count; j++)
                {
                    tempCard = surplusCardsList[j];
                    if (!tempCard.isUse && tempCard.key == key3)
                    {
                        temp3 = tempCard;
                        break;
                    }
                }

                if (temp2 != null && temp3 != null)
                {
                    //组成一个非听用顺子
                    temp = new MahjongP3Data();
                    temp.card1 = temp1;
                    temp.card2 = temp2;
                    temp.card3 = temp3;
                    temp1.isUse = true;
                    temp2.isUse = true;
                    temp3.isUse = true;
                    shunZiList.Add(temp);
                }
                else if (temp2 != null)
                {
                    //和2组成连续顺子
                    temp = new MahjongP3Data();
                    temp.type = 1;
                    temp.card1 = temp1;
                    temp.card2 = temp2;
                    temp1.isUse = true;
                    temp2.isUse = true;
                    shunZiTingList.Add(temp);
                }
                else if (temp3 != null)
                {
                    //和3组成卡顺子
                    temp = new MahjongP3Data();
                    temp.type = 2;
                    temp.card1 = temp1;
                    temp.card2 = temp3;
                    temp1.isUse = true;
                    temp3.isUse = true;
                    shunZiTingList.Add(temp);
                }
            }
        }
        for (int i = 0; i < surplusCardsList.Count; i++)
        {
            tempCard = surplusCardsList[i];
            if (!tempCard.isUse)
            {
                singleList.Add(tempCard);
            }
        }
    }

    private static int CheckMaxFanNumByShunZiTing(List<MahjongCheckData> handList, List<MahjongP3Data> shunZiTingList, List<MahjongCheckData> singleList)
    {
        if (shunZiTingList.Count == 0)
        {
            return CheckMaxFanNumBySingleTing(handList, singleList);
        }
        else
        {
            int length = shunZiTingList.Count;
            MahjongP3Data p3Card = null;
            MahjongCheckData temp = null;
            List<MahjongCheckData> newHandList = LoopCheckNewHandLists[length];
            List<MahjongP3Data> newShunZiTingList = LoopCheckNewShunZiTingList[length];
            newHandList.Clear();
            newShunZiTingList.Clear();
            p3Card = shunZiTingList[0];
            if (shunZiTingList.Count > 1)
            {
                for (int i = 1; i < shunZiTingList.Count; i++)
                {
                    newShunZiTingList.Add(shunZiTingList[i]);
                }
            }

            int maxFanNum = -1;
            int tempFanNum = -1;
            if (p3Card.type == 1)
            {
                //两个挨着，需要处理前后
                if (KeyMappingDict.TryGetValue(p3Card.card1.key - 1, out temp))
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(temp);
                    newHandList.Add(p3Card.card1);
                    newHandList.Add(p3Card.card2);

                    tempFanNum = CheckMaxFanNumByShunZiTing(newHandList, newShunZiTingList, singleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
                if (KeyMappingDict.TryGetValue(p3Card.card2.key + 1, out temp))
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(temp);
                    newHandList.Add(p3Card.card1);
                    newHandList.Add(p3Card.card2);

                    tempFanNum = CheckMaxFanNumByShunZiTing(newHandList, newShunZiTingList, singleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            else
            {
                //卡在中间
                if (KeyMappingDict.TryGetValue(p3Card.card1.key + 1, out temp))
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(p3Card.card1);
                    newHandList.Add(temp);
                    newHandList.Add(p3Card.card2);

                    tempFanNum = CheckMaxFanNumByShunZiTing(newHandList, newShunZiTingList, singleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            return maxFanNum;
        }
    }

    /// <summary>
    /// 检测番数，处理单牌听用成坎
    /// </summary>
    private static int CheckMaxFanNumBySingleTing(List<MahjongCheckData> handList, List<MahjongCheckData> singleList)
    {
        if (singleList.Count == 0)
        {
            return CheckFanNumByNoTing(handList);
        }
        else
        {
            int length = singleList.Count;
            MahjongCheckData card = singleList[0];
            List<MahjongCheckData> newSingleList = LoopNewSingleList[length];
            newSingleList.Clear();
            if (singleList.Count > 1)
            {
                for (int i = 1; i < singleList.Count; i++)
                {
                    newSingleList.Add(singleList[i]);
                }
            }
            List<MahjongCheckData> newHandList = LoopNewHandList[length];

            int maxFanNum = -1;
            int tempFanNum = -1;
            //当最左，需要判断 + 2
            if (card.num + 2 < 10)
            {
                newHandList.Clear();
                newHandList.AddRange(handList);
                newHandList.Add(card);
                newHandList.Add(KeyMappingDict[card.key + 1]);
                newHandList.Add(KeyMappingDict[card.key + 2]);
                tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
                if (tempFanNum > maxFanNum)
                {
                    maxFanNum = tempFanNum;
                }
            }
            //当中间，需要判断-1，+1
            //条
            if (card.type == 2)
            {
                if (card.num - 1 > 1 && card.num + 1 < 10)
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(KeyMappingDict[card.key - 1]);
                    newHandList.Add(card);
                    newHandList.Add(KeyMappingDict[card.key + 1]);
                    tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            else
            {
                //非条子
                if (card.num - 1 > 0 && card.num + 1 < 10)
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(KeyMappingDict[card.key - 1]);
                    newHandList.Add(card);
                    newHandList.Add(KeyMappingDict[card.key + 1]);
                    tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            //当最右，需要判断 - 2
            //条
            if (card.type == 2)
            {
                if (card.num - 2 > 1)
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(KeyMappingDict[card.key - 2]);
                    newHandList.Add(KeyMappingDict[card.key - 1]);
                    newHandList.Add(card);
                    tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            else
            {
                //非条子
                if (card.num - 2 > 0)
                {
                    newHandList.Clear();
                    newHandList.AddRange(handList);
                    newHandList.Add(KeyMappingDict[card.key - 2]);
                    newHandList.Add(KeyMappingDict[card.key - 1]);
                    newHandList.Add(card);
                    tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
                    if (tempFanNum > maxFanNum)
                    {
                        maxFanNum = tempFanNum;
                    }
                }
            }
            //3同
            newHandList.Clear();
            newHandList.AddRange(handList);
            newHandList.Add(card);
            newHandList.Add(card);
            newHandList.Add(card);
            tempFanNum = CheckMaxFanNumBySingleTing(newHandList, newSingleList);
            if (tempFanNum > maxFanNum)
            {
                maxFanNum = tempFanNum;
            }
            return maxFanNum;
        }
    }
}
