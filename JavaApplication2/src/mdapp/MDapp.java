/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package mdapp;

import database.DBUtils_imp;
import database.DButils;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author piotr
 */
public class MDapp {

    /**
     * @param args the command line arguments
     */
    static Connection conn=null;
    public static void main(String[] args) {
      
        try {
            DButils test = new DBUtils_imp();
//            String nounce =  test.getStringNounce(5);
//            System.out.println(nounce);
              Vector<Vector<String>> a = test.browseHistory(5, 1, null, null, false, null, null);
              TestMock.printf(a);
            
        } catch (SQLException ex) {
            Logger.getLogger(MDapp.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        Main m = new Main();
        m.setVisible(true);
        
//        String url = "jdbc:postgresql://192.168.1.21/project?user=test&password=test";
//        try {
//            conn = DriverManager.getConnection(url);
//            
//            Statement st = conn.createStatement();
//            ResultSet rs = st.executeQuery("SELECT * FROM patients");
//            while (rs.next()) {
//                System.out.print("Column 1 returned ");
//                System.out.println(rs.getString(2));
//            }
//            rs.close();
//            st.close();
//            
//        } catch (SQLException ex) {
//            System.out.println("Error sql");
//            Logger.getLogger(MDapp.class.getName()).log(Level.SEVERE, null, ex);
//        }
    }
    
}
