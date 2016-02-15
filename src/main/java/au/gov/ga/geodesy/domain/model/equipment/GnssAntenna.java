package au.gov.ga.geodesy.domain.model.equipment;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity(name = "geodesy.GnssAntenna")
@DiscriminatorValue("gnss antenna")
public class GnssAntenna extends Equipment {

    private GnssAntenna() {
        super(null, null);
    }

    public GnssAntenna(String type, String serialNumber) {
        super(type, serialNumber);
    }
}
