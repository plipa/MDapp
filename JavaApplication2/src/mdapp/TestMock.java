/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package mdapp;

import java.io.IOException;
import java.util.Stack;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author piotr
 */
public class TestMock {
    
    static void setTestTableListPatient(javax.swing.JTable tab,String PATH){
        DefaultTableModel model = (DefaultTableModel) tab.getModel();
        FileDB a;
        try {
            a = new FileDB(PATH);
            Vector<Vector<String>> vec = a.parseDB();
            for(Vector<String> v : vec){
                model.addRow(v);
            }
        } catch (IOException ex) {
            Logger.getLogger(TestMock.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        
//        Vector row = new Vector();
//        row.add("1");
//        row.add("Piotr");
//        row.add("Lipiak");
//        row.add("123456789");
//        model.addRow(row);
//        
//        Vector row2 = new Vector();
//        row2.add("2");
//        row2.add("Krystian");
//        row2.add("Krakowiak");
//        row2.add("123456789");
//        model.addRow(row2);
        
    }
    
    static void saveTableToFile(javax.swing.JTable tab,String PATH){
        try {
            DefaultTableModel model = (DefaultTableModel) tab.getModel();
            Vector a = new Vector();
            for(int i=0;i<model.getRowCount();i++){
                Vector<String> tmp = new Vector<String>();
                for (int j = 0; j < model.getColumnCount(); j++) {
                    if(model.getValueAt(i, j) instanceof Integer){
                       tmp.add(String.valueOf(model.getValueAt(i, j))); 
                    }else{
                        tmp.add((String)model.getValueAt(i, j));
                    }
                }
                a.add(tmp);
                
            }
            FileDB.toFile(a, PATH);
            //model.get
        } catch (IOException ex) {
            Logger.getLogger(TestMock.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    static Vector<Vector<String>> convertTableToVector(javax.swing.JTable tab){
            DefaultTableModel model = (DefaultTableModel) tab.getModel();
            Vector a = new Vector();
            for(int i=0;i<model.getRowCount();i++){
                Vector<String> tmp = new Vector<String>();
                for (int j = 0; j < model.getColumnCount(); j++) {
                    if(model.getValueAt(i, j) instanceof Integer){
                       tmp.add(String.valueOf(model.getValueAt(i, j))); 
                    }else{
                        tmp.add((String)model.getValueAt(i, j));
                    }
                }
                a.add(tmp);
                
            }
            return a;
            //model.get
    }
    
    static DefaultTableModel convertVectorToModelTable(Vector<Vector<String>> vec, javax.swing.JTable tab){
        DefaultTableModel model = (DefaultTableModel) tab.getModel();
        for (Vector<String> vector : vec) {
            model.addRow(vector);
        }
        return model;
    }
    
    static void printf(Vector<Vector<String>> vec){
        for (Vector<String> vector : vec) {
            for (String string : vector) {
                System.out.print(string+ " ");
            }
            System.out.println();
        }
    }
    
}
