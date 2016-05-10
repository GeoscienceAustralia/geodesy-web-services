package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import java.util.function.Function;

import au.gov.ga.geodesy.domain.model.sitelog.SiteIdentification;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLocation;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.support.java.util.Isomorphism;
import au.gov.xml.icsm.geodesyml.v_0_3.SiteIdentificationType;
import au.gov.xml.icsm.geodesyml.v_0_3.SiteLocationType;
import au.gov.xml.icsm.geodesyml.v_0_3.SiteLogType;

import ma.glasnost.orika.MapperFacade;
import ma.glasnost.orika.MapperFactory;
import ma.glasnost.orika.converter.ConverterFactory;
import ma.glasnost.orika.impl.DefaultMapperFactory;

/**
 * Reversible mapping between GeodesyML SiteLogType DTO and
 * SiteLog site log entity.
 */
public class SiteLogMapper implements Isomorphism<SiteLogType, SiteLog> {

    private MapperFactory mapperFactory = new DefaultMapperFactory.Builder().build();

    private MapperFacade mapper;

    public SiteLogMapper() {
        mapperFactory.classMap(SiteLogType.class, SiteLog.class)
            .fieldMap("siteIdentification", "siteIdentification").converter("siteIdentification").add()
            .fieldMap("siteLocation", "siteLocation").converter("siteLocation").add()
            /* .byDefault() */
            .register();

        ConverterFactory converters = mapperFactory.getConverterFactory();

        converters.registerConverter("siteIdentification",
                new IsomorphismConverter<SiteIdentificationType, SiteIdentification>(new SiteIdentificationMapper()) {});

        converters.registerConverter("siteLocation",
                new IsomorphismConverter<SiteLocationType, SiteLocation>(new SiteLocationMapper()) {});

        mapper = mapperFactory.getMapperFacade();
    }

    /**
     * {@inheritDoc}
     */
    public Function<SiteLogType, SiteLog> to() {
        return siteLogType -> mapper.map(siteLogType, SiteLog.class);
    }

    /**
     * {@inheritDoc}
     */
    public Function<SiteLog, SiteLogType> from() {
        return siteLog -> mapper.map(siteLog, SiteLogType.class);
    }
}
