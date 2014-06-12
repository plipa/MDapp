/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

public interface DButils {
    
    ResultSet executeQuery(String query) throws SQLException;
    byte[]    getNounce(int doctors_id)throws SQLException;
    Vector<Vector<String>>  browseMedicine          (String name, String type)throws SQLException;
    Vector<Vector<String>>  browseDoctors           (String name, String address, int license_number)throws SQLException;
    void                    createPrescription      (int doctor_id, int patient_id, int drug_id,int dosage, int unit, int quantity, byte[] signature)throws SQLException;
    Vector<Vector<String>>  browseHistory           (int doctor_id, int patient_id, String start, String end, boolean bought, byte[] doctors_sign, byte[] patient_sign)throws SQLException;
    Vector<Vector<String>>  convertResultSetToVector(ResultSet set)throws SQLException; 
    
}
