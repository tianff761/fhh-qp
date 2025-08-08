
public class ExceptionUtil
{
    static int LENGTH_1 = 100;
    static int LENGHT_2 = 250;
    static int KEY_COUNT_1 = 100;
    static int KEY_COUNT_2 = 50;
    static byte KEY_1 = 3;
    static byte KEY_2 = 1;
    static byte KEY_3 = 2;

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

                for (int i = LENGHT_2; i < length; i++) 
                {
                    bytes[i] -= KEY_3;
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

                for (int i = LENGHT_2; i < length; i++)
                {
                    bytes[i] += KEY_3;
                }
            }
        }
        return bytes;
    }
}
