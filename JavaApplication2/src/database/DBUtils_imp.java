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
        String url = "jdbc:postgresql://www.kubaplas.pl/project?user=doctor1&password=doctor";
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
        ResultSet s = executeQuery("select get_doctor_nonce("+Integer.toString(doctors_id)+")");
        byte[] nounce = s.getBytes(0);
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
        ResultSet s = executeQuery("select create_prescription("+doctor_id+","+drug_id+","+dosage+","+unit+","+quantity+","+signature+")"); 
    }

    @Override
    public Vector<Vector<String>> browseHistory(int doctor_id, int patient_id, String start, String end, boolean bought, byte[] doctors_sign, byte[] patient_sign) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
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
    
}
