/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author DELL
 */
public class DbContext {
    
    protected Connection connection;

    public DbContext() {
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            String user = "sa";
            String pass = "1234567890";
            String url = "jdbc:sqlserver://localhost:1433;"
           + "databaseName=ITServiceFlow;"
           + "encrypt=true;"
           + "trustServerCertificate=true;"
           + "loginTimeout=5;";

            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException ex) {
            System.err.println("SQL Server JDBC Driver not found. Please add mssql-jdbc.jar to your classpath.");
            ex.printStackTrace();
            connection = null;
        } catch (Exception ex) {
            System.err.println("Connection Error: " + ex.getMessage());
            System.err.println("Please check:");
            System.err.println("1. SQL Server is running");
            System.err.println("2. Database 'ITServiceFlow' exists");
            System.err.println("3. Username and password are correct");
            System.err.println("4. SQL Server is listening on port 1433");
            ex.printStackTrace();
            connection = null;
        }
    }

    public boolean isConnected() {
        return connection != null;
    }

    protected boolean hasConnection() {
        return connection != null;
    }

    protected boolean hasTable(String tableName) {
        if (!hasConnection() || tableName == null || tableName.trim().isEmpty()) {
            return false;
        }
        try {
            DatabaseMetaData metaData = connection.getMetaData();
            String catalog = connection.getCatalog();
            if (tableExists(metaData, catalog, "dbo", tableName)) {
                return true;
            }
            return tableExists(metaData, catalog, null, tableName);
        } catch (SQLException ex) {
            return false;
        }
    }

    protected boolean hasColumn(String tableName, String columnName) {
        if (!hasConnection()
                || tableName == null || tableName.trim().isEmpty()
                || columnName == null || columnName.trim().isEmpty()) {
            return false;
        }
        try {
            DatabaseMetaData metaData = connection.getMetaData();
            String catalog = connection.getCatalog();
            if (columnExists(metaData, catalog, "dbo", tableName, columnName)) {
                return true;
            }
            return columnExists(metaData, catalog, null, tableName, columnName);
        } catch (SQLException ex) {
            return false;
        }
    }

    private boolean tableExists(DatabaseMetaData metaData, String catalog, String schema, String tableName) throws SQLException {
        try (ResultSet rs = metaData.getTables(catalog, schema, tableName, new String[]{"TABLE"})) {
            return rs.next();
        }
    }

    private boolean columnExists(DatabaseMetaData metaData, String catalog, String schema, String tableName, String columnName) throws SQLException {
        try (ResultSet rs = metaData.getColumns(catalog, schema, tableName, columnName)) {
            return rs.next();
        }
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
