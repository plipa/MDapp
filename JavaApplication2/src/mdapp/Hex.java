/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package mdapp;

import java.io.IOException;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;
/**
 *
 * @author sevar
 */
public class Hex {

    static BASE64Decoder dec64 = new BASE64Decoder();
    static BASE64Encoder enc64 = new BASE64Encoder();
    
    public static byte[] concatenateByteArrays(byte[] a, byte[] b) {
        byte[] result = new byte[a.length + b.length]; 
        System.arraycopy(a, 0, result, 0, a.length); 
        System.arraycopy(b, 0, result, a.length, b.length); 
        return result;
    } 
    
//    public static byte[] removeSignByte(String toString) {
//        if(toString.length()%2==1)
//        {
//            return org.bouncycastle.util.encoders.Hex.decode("0"+toString);
//        }
//        return Hex.stringHexToByteHex(toString);
//    }
    
    public static short bytesToshort(byte b1, byte b2)
    {
        return (short)( ((b1&0xFF)<<8) | (b2&0xFF) );
    }
    public static String byteToHexString(byte b)
    {
        byte[] tab = {b};
        return byteHextoStringHex(tab);
        
    }
    public static byte[] stringHexToByteHex(String s) {

        if (s.equals(new String(""))) {
            return new byte[0];
        }
        s = s.replaceAll(" ", "");

        //if ((s.length() % 2) != 0) {
        //    throw new IllegalArgumentException("String len is odd");
        //}

        byte[] data = new byte[s.length() / 2];
        for (int i = 0; i < s.length(); i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;

    }

    public static String byteHextoString(byte[] b) {
        String s = "";
        for (int i = 0; i < b.length; i++) {
            if (b[i] == 0) {
                s = s.concat("0").concat("");
            } else {
                s = s.concat((Integer.toString(b[i]))).concat("");
            }
        }

        return s;
    }

    
    public static String byteHextoStringHex(byte[] b) {
        String s = "";
        for (int i = 0; i < b.length; i++) {
            if ((byte)0x00 <= b[i] && b[i] <= (byte)0x0f) {
                s = s.concat("0").concat(Integer.toHexString(b[i])).concat(" ");
            } else {
                s = s.concat((Integer.toHexString(b[i]))).concat(" ");
            }
        }
        s = s.replace("ffffff", "");

        return s;
    }
    
    public static String byteHextoStringHex(byte[] b, int offset, int len) {
        String s = "";
        for (int i = offset; i < len; i++) {
            if ((byte)0x00 <= b[i] && b[i] <= (byte)0x0f) {
                s = s.concat("0").concat(Integer.toHexString(b[i])).concat(" ");
            } else {
                s = s.concat((Integer.toHexString(b[i]))).concat(" ");
            }
        }
        s = s.replace("ffffff", "");

        return s;
    }
    public static String shorttoStringHex(short x) {
        String s="";
        byte[] ret=new byte[2];
        ret[1] = (byte)(x & 0xff);
        
        ret[0] = (byte)((x >> 8) & 0xff);
        
        s =(byteHextoStringHex(ret));
        
        return s;
    }
    
    public static byte[] dec64(String what){
        try {
            return dec64.decodeBuffer(what);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return null;
    }
    
    public static String enc64(byte[] what){
        return enc64.encode(what);
    }

    public static void main(String[] args) {
        String s = "";
        short n = (short)0x7f21;
        System.out.println(shorttoStringHex(n));
    }
}
