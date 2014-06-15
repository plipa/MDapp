/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;


public class DBUtils_imp implements DButils{
Connection conn=null;
    
    
    public DBUtils_imp() throws SQLException {
        String url = "jdbc:postgresql://192.168.1.24/test?user=postgres&password=p1lipa";
        conn = DriverManager.getConnection(url);
    }

    
    @Override
    public ResultSet executeQuery(String query) throws SQLException {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(query);
            return rs;
    }

    @Override
    public byte[] getNounce(int doctors_id) throws SQLException {
        String nounce = null;
        ResultSet s = executeQuery("select get_doctor_nonce("+Integer.toString(doctors_id)+")");
        if(s.next()){
        nounce = s.getString(1);
            //System.out.println(s.getString(1));
        }
        
        return nounce.getBytes();
    }
    
    @Override
    public String getStringNounce(int doctors_id) throws SQLException {
        String nounce = null;
        ResultSet s = executeQuery("select get_doctor_nonce("+Integer.toString(doctors_id)+")");
        if(s.next()){
        nounce = s.getString(1);
            //System.out.println(s.getString(1));
        }
        
        return nounce;
    }

    @Override
    public Vector<Vector<String>> browseMedicine(String name, String type) throws SQLException {
        ResultSet s = executeQuery("select browse_medicines("+name+","+type+")");
        return convertResultSetToVector(s);
    }

    @Override
    public Vector<Vector<String>> browseDoctors(String name, String address, int license_number) throws SQLException {
        ResultSet s = executeQuery("select browse_doctors("+name+","+address+","+String.valueOf(license_number)+")"); 
        return convertResultSetToVector(s);
    }

    @Override
    public void createPrescription(int doctor_id, int patient_id, int drug_id, int dosage, int unit, int quantity, byte[] signature) throws SQLException {
        ResultSet s = executeQuery("select create_prescription("+doctor_id+","+patient_id+","+drug_id+","+dosage+","+unit+","+quantity+",'aa'::bytea)"); 
    }

    @Override
    public Vector<Vector<String>> browseHistory(int doctor_id, int patient_id, String start, String end, boolean bought, byte[] doctors_sign, byte[] patient_sign) throws SQLException {
//        String query = "select browse_patient_prescription_history2("+doctor_id+","+patient_id+","+start+","+end+","+String.valueOf(bought)+","+doctors_sign+","+patient_sign+");";
        String query = "select browse_patient_prescription_history2("+doctor_id+","+patient_id+","+start+","+end+","+String.valueOf(bought)+",null,null);";
//        System.out.println(query);
        ResultSet s = executeQuery(query);
        
        return convertStringResultSetToVectorforBrowser(s);
    }

    @Override
    public Vector<Vector<String>> convertResultSetToVector(ResultSet set) throws SQLException {
        ResultSetMetaData rsmd = set.getMetaData();

        int columnsNumber = rsmd.getColumnCount();
        Vector ret = new Vector();
        while(set.next()){
            Vector<String> a = new Vector<String>();
            for (int i = 0; i < columnsNumber; i++) {
                a.add(String.valueOf(set.getObject(i)));
            }
            ret.add(a);
        }
        return ret;
    }
    
    
    public Vector<Vector<String>> convertStringResultSetToVectorforBrowser(ResultSet set) throws SQLException {
        ResultSetMetaData rsmd = set.getMetaData();

        int columnsNumber = rsmd.getColumnCount();
        Vector ret = new Vector();
        while(set.next()){
            Vector<String> a = new Vector<String>();
            String temp = set.getString(1);
            String[] tab = temp.split(",");
            
            for (int i=0;i<tab.length;i++) {
                if (i==0||i==1||i==2||i==3||i==4||i==6||i==7||i==9||i==10) {
                    a.add(tab[i].replace("(", "").replace("\"", ""));
                }
                
                
            }
            ret.add(a);
        }
        return ret;
    }
}
