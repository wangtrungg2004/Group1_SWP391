package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Locations;

/**
 * Data Access Object for Locations.
 * Handles all database operations related to the Locations table.
 */
public class LocationsDAO extends DbContext {

    /**
     * Retrieves all active locations from the database.
     * @return List of active Locations
     */
    public List<Locations> getAllLocations() {
        List<Locations> list = new ArrayList<>();
        String sql = "SELECT Id, Name, Code, IsActive FROM Locations WHERE IsActive = 1 ORDER BY Name ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToLocation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Retrieves a location by its ID.
     * @param id The ID of the location to retrieve
     * @return The Location object, or null if not found
     */
    public Locations getLocationById(int id) {
        String sql = "SELECT Id, Name, Code, IsActive FROM Locations WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToLocation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Retrieves a location by its unique code.
     * @param code The code of the location to retrieve
     * @return The Location object, or null if not found
     */
    public Locations getLocationByCode(String code) {
        String sql = "SELECT Id, Name, Code, IsActive FROM Locations WHERE Code = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToLocation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Adds a new location to the database.
     * @param loc The location object to add
     * @return true if added successfully, false otherwise
     */
    public boolean addLocation(Locations loc) {
        String sql = "INSERT INTO Locations (Name, Code, IsActive) VALUES (?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, loc.getName());
            ps.setString(2, loc.getCode());
            ps.setBoolean(3, loc.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates an existing location in the database.
     * @param loc The location object with updated data
     * @return true if updated successfully, false otherwise
     */
    public boolean updateLocation(Locations loc) {
        String sql = "UPDATE Locations SET Name = ?, Code = ?, IsActive = ? WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, loc.getName());
            ps.setString(2, loc.getCode());
            ps.setBoolean(3, loc.isActive());
            ps.setInt(4, loc.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Performs a soft delete by deactivating a location.
     * @param id The ID of the location to deactivate
     * @return true if deactivated successfully, false otherwise
     */
    public boolean deactivateLocation(int id) {
        String sql = "UPDATE Locations SET IsActive = 0 WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Helper method to map a ResultSet row to a Locations object.
     */
    private Locations mapRowToLocation(ResultSet rs) throws SQLException {
        Locations loc = new Locations();
        loc.setId(rs.getInt("Id"));
        loc.setName(rs.getString("Name"));
        loc.setCode(rs.getString("Code"));
        loc.setIsActive(rs.getBoolean("IsActive"));
        return loc;
    }
}
