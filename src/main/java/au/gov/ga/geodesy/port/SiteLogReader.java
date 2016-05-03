package au.gov.ga.geodesy.port;

import java.io.Reader;

import au.gov.ga.geodesy.exception.GeodesyRuntimeException;

public abstract class SiteLogReader implements SiteLogSource {

    private Reader input;

    public void setSiteLogReader(Reader input) {
        this.input = input;
    }
    
    
    public Reader getSiteLogReader() {
        if (input == null) {
            throw new GeodesyRuntimeException("SiteLogReader must be set first!");
        }
        return input;
    }
}
