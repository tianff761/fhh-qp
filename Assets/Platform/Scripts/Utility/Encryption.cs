
public class Encryption
{
    static int LENGTH_1 = 20;
    static int LENGHT_2 = 100;
    static int KEY_COUNT_1 = 100;
    static int KEY_COUNT_2 = 50;
    static byte KEY_1 = 2;
    static byte KEY_2 = 1;
    static int STEP = 150;

    public static byte[] Encode(byte[] bytes)
    {
        int length = bytes.Length;

        if (length < LENGTH_1)
        {
            for (int i = 0; i < length; i++)
            {
                bytes[i] -= KEY_1;
            }
        }
        else
        {
            for (int i = 0; i < LENGTH_1; i++)
            {
                bytes[i] += (byte)(KEY_COUNT_1 - i);
            }

            if (length < LENGHT_2)
            {
                for (int i = LENGTH_1; i < length; i++)
                {
                    bytes[i] -= KEY_2;
                }
            }
            else
            {
                for (int i = LENGTH_1; i < LENGHT_2; i++)
                {
                    bytes[i] += (byte)(KEY_COUNT_2 - i);
                }

                int step = (bytes.Length - LENGHT_2) / STEP;
                if (step < 1) { step = 1; }
                int total = (bytes.Length - LENGHT_2) / step;
                int index = 0;
                for (int i = 0; i < total; i++)
                {
                    index = LENGHT_2 + i * step;
                    bytes[index] -= (byte)(index % 5);
                }
            }
        }
        return bytes;
    }

    public static byte[] Decode(byte[] bytes)
    {
        int length = bytes.Length;

        if (length < LENGTH_1)
        {
            for (int i = 0; i < length; i++)
            {
                bytes[i] += KEY_1;
            }
        }
        else
        {
            for (int i = 0; i < LENGTH_1; i++)
            {
                bytes[i] -= (byte)(KEY_COUNT_1 - i);
            }

            if (length < LENGHT_2)
            {
                for (int i = LENGTH_1; i < length; i++)
                {
                    bytes[i] += KEY_2;
                }
            }
            else
            {
                for (int i = LENGTH_1; i < LENGHT_2; i++)
                {
                    bytes[i] -= (byte)(KEY_COUNT_2 - i);
                }

                int step = (bytes.Length - LENGHT_2) / STEP;
                if (step < 1) { step = 1; }
                int total = (bytes.Length - LENGHT_2) / step;
                int index = 0;
                for (int i = 0; i < total; i++)
                {
                    index = LENGHT_2 + i * step;
                    bytes[index] += (byte)(index % 5);
                }
            }
        }
        return bytes;
    }
}
