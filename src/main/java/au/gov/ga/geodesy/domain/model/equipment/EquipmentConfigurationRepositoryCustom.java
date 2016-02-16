package au.gov.ga.geodesy.domain.model.equipment;

import java.util.Date;

public interface EquipmentConfigurationRepositoryCustom {
    <T extends EquipmentConfiguration> T findOne(Class<T> configClass, Integer equipId, Date configurationTime);
}
