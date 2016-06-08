package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.domain.model.sitelog.EffectiveDates;
import au.gov.ga.geodesy.domain.model.sitelog.RadioInterference;
import au.gov.ga.geodesy.support.java.util.Iso;
import au.gov.ga.geodesy.support.mapper.orika.converters.AbstractTimePrimitiveTypeEffectiveDatesConverter;
import au.gov.ga.geodesy.support.mapper.orika.converters.TimePeriodTypeEffectiveDatesConverter;
import au.gov.xml.icsm.geodesyml.v_0_3.RadioInterferencesType;
import ma.glasnost.orika.MapperFacade;
import ma.glasnost.orika.MapperFactory;
import ma.glasnost.orika.converter.ConverterFactory;
import ma.glasnost.orika.impl.DefaultMapperFactory;
import net.opengis.gml.v_3_2_1.TimePeriodType;

/**
 * Reversible mapping between GeodesyML RadioInterferencesType DTO and
 * RadioInterference site log entity.
 */
public class RadioInterferenceMapper implements Iso<RadioInterferencesType, RadioInterference> {

    private MapperFactory mapperFactory = new DefaultMapperFactory.Builder().build();
    private MapperFacade mapper;

    public RadioInterferenceMapper() {
        mapperFactory.classMap(RadioInterferencesType.class, RadioInterference.class)
                .fieldMap("possibleProblemSources", "possibleProblemSource").add()
                .fieldMap("observedDegradations", "observedDegradation").add()
                .fieldMap("validTime.abstractTimePrimitive", "effectiveDates").converter("jaxbElementConverter").add()
                .byDefault()
                .register();

        ConverterFactory converters = mapperFactory.getConverterFactory();
        // TimePeriodTypeEffectiveDatesConverter- Needed to map from DTO to Entity
        TimePeriodTypeEffectiveDatesConverter timePeriodTypeEffectiveDatesConverter = new TimePeriodTypeEffectiveDatesConverter();
        // AbstractTimePrimitiveTypeEffectiveDatesConverter - Needed to map from Entity to DTO
        AbstractTimePrimitiveTypeEffectiveDatesConverter abstractTimePrimitiveTypeEffectiveDatesConverter = new AbstractTimePrimitiveTypeEffectiveDatesConverter();
        converters.registerConverter(timePeriodTypeEffectiveDatesConverter);
        converters.registerConverter(abstractTimePrimitiveTypeEffectiveDatesConverter);
        converters.registerConverter("jaxbElementConverter", new JAXBElementConverter<TimePeriodType, EffectiveDates>() {
        });
        mapper = mapperFactory.getMapperFacade();
    }

    @Override
    /**
     * {@inheritDoc}
     */
    public RadioInterference to(RadioInterferencesType radioInterferencesType) {
        return mapper.map(radioInterferencesType, RadioInterference.class);
    }

    @Override
    /**
     * {@inheritDoc}
     */
    public RadioInterferencesType from(RadioInterference radioInterference) {
        return mapper.map(radioInterference, RadioInterferencesType.class);
    }
}
