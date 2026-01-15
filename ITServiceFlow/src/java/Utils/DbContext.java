/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author DELL
 */
public class DbContext {
    
    protected Connection connection;
    public DbContext() {
        try {
            String user = "sa";
            String pass = "123";
            String url = "jdbc:sqlserver://localhost:1433;"
                       + "databaseName=ITServiceFlow;"
                       + "encrypt=true;"
                       + "trustServerCertificate=true";
                       Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (Exception ex) {
            System.out.println("Connection Error");
            ex.printStackTrace();
        }
    }

    public boolean isConnected() {
        return connection != null;
    }
    
    public static void main(String[] args) {
        DbContext dbContext = new DbContext();
        try{
            if (dbContext.isConnected()) {
            System.out.println("Successfully connected");
        } else {
            System.out.println("Failed to connected");
        }
        }
        catch(Exception ex)
        {
            System.out.println(ex);
        }
    }
}
