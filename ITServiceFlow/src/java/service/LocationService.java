package service;

import dao.LocationDao;
import model.Location;

import java.util.List;

/**
 * Service cho Location.
 */
public class LocationService {
    private final LocationDao dao = new LocationDao();

    public List<Location> getAllLocations() {
        return dao.getAllLocations();
    }

    public Location getById(int id) {
        return dao.getById(id);
    }
}
