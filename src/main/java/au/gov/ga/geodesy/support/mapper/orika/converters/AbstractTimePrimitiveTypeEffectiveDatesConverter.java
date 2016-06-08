package au.gov.ga.geodesy.support.mapper.orika.converters;

import au.gov.ga.geodesy.domain.model.sitelog.EffectiveDates;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;
import ma.glasnost.orika.MappingContext;
import ma.glasnost.orika.converter.BidirectionalConverter;
import ma.glasnost.orika.metadata.Type;
import net.opengis.gml.v_3_2_1.AbstractTimePrimitiveType;
import net.opengis.gml.v_3_2_1.TimePeriodType;
import net.opengis.gml.v_3_2_1.TimePositionType;

import java.time.Instant;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Convert AbstractTimePrimitiveType <-> EffectiveDates
 * Same as TimePeriodType <-> EffectiveDates (TimePeriodTypeEffectiveDatesConverter) but needed for convertFrom
 */
public class AbstractTimePrimitiveTypeEffectiveDatesConverter extends BidirectionalConverter<AbstractTimePrimitiveType, EffectiveDates> {

    @Override
    public EffectiveDates convertTo(AbstractTimePrimitiveType abstractTimePrimitiveType, Type<EffectiveDates> type, MappingContext mappingContext) {
        TimePeriodType timePeriodType = (TimePeriodType) abstractTimePrimitiveType;
        Instant fromDate = GMLDateUtils.stringToDateMultiParsers(timePeriodType.getBeginPosition().getValue().get(0));
        Instant toDate = GMLDateUtils.stringToDateMultiParsers(timePeriodType.getEndPosition().getValue().get(0));

        EffectiveDates ed = new EffectiveDates();

        ed.setFrom(fromDate);
        ed.setTo(toDate);
        return ed;
    }

    @Override
    public AbstractTimePrimitiveType convertFrom(EffectiveDates effectiveDates, Type<AbstractTimePrimitiveType> type, MappingContext mappingContext) {
        return TimePeriodTypeEffectiveDatesConverter.convertFromDelegate(effectiveDates, type, mappingContext);
    }
}
