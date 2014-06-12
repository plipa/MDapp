/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package mdapp;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Iterator;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sevar
 */
public class FileDB {

    StringBuilder content = null;

    public FileDB(String PATH) throws IOException {
        try {
            content = new StringBuilder();
            FileInputStream fis = new FileInputStream(PATH);
            while (fis.available() > 0) {
                content.append((char) fis.read());
            }
            fis.close();
        } catch (FileNotFoundException ex) {
            Logger.getLogger(FileDB.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public Vector<Vector<String>> parseDB() {

        String content_string = content.toString().replace("  ", " ").replace("\t", " ");
        String[] rows = content_string.split("\n");
        Vector<Vector<String>> retVal = new Vector<>();
        Vector<String> tmp = new Vector<>();

        for (int i = 0; i < rows.length; i++) {
            //tmp.clear();
            tmp = new Vector<>();
            
            String[] a = rows[i].split(" ");
            for (int j = 0; j < a.length; j++) {
                //System.out.println(a[j] +" ");
                tmp.add(a[j].replace("\n", "").replace("\r ", "").replace("\t", "").replace(" ", "").replace(new String(""+(char)0x0d),""));
            }
            retVal.add(tmp);
        }
        return retVal;

    }

    public void printVectorTab(Vector<Vector<String>> vec) {
        //System.out.println(vec.size());
        for (Vector<String> v : vec) {            
            for (String s : v) {
                System.out.print(s+" ");
            }
            System.out.println();
        }
    }

    public static void toFile(Vector<Vector<String>> vec, String PATH) throws IOException{
        System.out.println("toFile");
        Files.deleteIfExists(Paths.get(PATH));
        FileOutputStream fos = new FileOutputStream(PATH);
        for (Vector<String> v : vec) {            
            for (String s : v) {
                
                fos.write(s.getBytes("US-ASCII"));
                fos.write((byte)32);
                //System.out.print(s+" ");
            }
            fos.write((byte)10);
        }
        fos.close();
    }
    public static void main(String[] args) throws IOException {
        FileDB f = new FileDB("D:\\patients.txt");
        //System.out.println(f.content.toString());
        Vector<Vector<String>> parseDB = f.parseDB();
        f.printVectorTab(parseDB);
        f.toFile(parseDB, "D:\\test.txt");



    }
}
