using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        MahjongHelper.Initialize();
        double time = Util.GetTime();

        int[] tempCards = new int[] { 101, 102, 103, 301, 302, 303, 401, 402, 501, 701, 702, 801, 901, 902 };

        //List<MahjongCheckData> handCardDatas = new List<MahjongCheckData>();
        //for (int i = 0; i < tempCards.Length; i++)
        //{
        //    handCardDatas.Add(new MahjongCheckData(tempCards[i]));
        //}
        //bool result2 = MahjongHelper.CheckIsHu(handCardDatas);

        MahjongHelper.SetRules(13, 1, 0, true, true, true, true, true);
        MahjongHelper.SetLeftCards( new MahjongLeftData[] { new MahjongLeftData(2301, 5) });
       // MahjongHelper.SetLeftCards(new MahjongLeftData[0]);

        //int[] temp = new int[] { 1101, 102, 203, 301, 302, 303, 401, 402, 501, 701, 702, 901, 901 };

        //int[] temp = new int[] { 1101, 102, 703, 301, 302, 303, 401, 402, 401, 701, 702, 901, 901 };
        //int[] temp = new int[] { 401, 501, 601, 602, 701, 2201, 2301, 2401, 2501, 2701 };

        int[] temp = new int[] { 1401, 1501, 1601, 1701, 1801, 2501, 2601, 2701, 2901, 2901 };

        MahjongResultData[] result = MahjongHelper.Check(temp, 0);
        Debug.LogError((Util.GetTime() - time).ToString());
        MahjongResultData data = null;
        if (result != null)
        {
            for (int i = 0; i < result.Length; i++)
            {
                data = result[i];
                Debug.LogError(data.key + " - " + data.list.Length);
                for (int j = 0; j < data.list.Length; j++)
                {
                    Debug.LogWarning(data.list[j].key + " > " + data.list[j].fanNum);
                }
            }
        }
        
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
