/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;


public class DBUtils_imp implements DButils{
Connection conn=null;
    
    
    public DBUtils_imp() throws SQLException {
        String url = "jdbc:postgresql://192.168.1.21/project?user=test&password=test";
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
        ResultSet s = executeQuery("select get_doctor_nonce()");
        byte[] nounce = s.getBytes(0);
        return nounce;
    }

    @Override
    public Vector<Vector<String>> browseMedicine(String name, String type) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Vector<Vector<String>> browseDoctors(String name, String address, int license_number) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void createPrescription(int doctor_id, int patient_id, int drug_id, int dosage, int unit, int quantity, byte[] signature) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Vector<Vector<String>> browseHistory(int doctor_id, int patient_id, String start, String end, boolean bought, byte[] doctors_sign, byte[] patient_sign) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Vector<Vector<String>> convertResultSetToVector(ResultSet set) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
    
}
