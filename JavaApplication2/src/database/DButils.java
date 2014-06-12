/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.Vector;

/**
 *
 * @author wro00571
 */
public interface DButils {
    
    ResultSet executeQuery(String query);
    byte[]    getNounce(int doctors_id);
    Vector<Vector<String>>  browseMedicine          (String name, String type);
    Vector<Vector<String>>  browseDoctors           (String name, String address, int license_number);
    void                    createPrescription      (int doctor_id, int patient_id, int drug_id,int dosage, int unit, int quantity, byte[] signature);
    Vector<Vector<String>>  browseHistory           (int doctor_id, int patient_id, String start, String end, boolean bought, byte[] doctors_sign, byte[] patient_sign);
    Vector<Vector<String>>  convertResultSetToVector(ResultSet set); 
    
}
