package au.gov.ga.geodesy.support.mapper.orika.converters;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import au.gov.ga.geodesy.domain.model.sitelog.EffectiveDates;
import au.gov.ga.geodesy.support.mapper.orika.BidirectionalAssignableConverter;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;

import ma.glasnost.orika.MappingContext;
import ma.glasnost.orika.metadata.Type;

import net.opengis.gml.v_3_2_1.TimePeriodType;
import net.opengis.gml.v_3_2_1.TimePositionType;

/**
 * Convert TimePeriodType <-> EffectiveDates
 */
public class TimePeriodTypeEffectiveDatesConverter extends BidirectionalAssignableConverter<TimePeriodType, EffectiveDates> {

    @Override
    public EffectiveDates convertTo(TimePeriodType timePeriodType, Type<EffectiveDates> type, MappingContext mappingContext) {
        Instant fromDate = GMLDateUtils.stringToDateMultiParsers(timePeriodType.getBeginPosition().getValue().get(0));
        Instant toDate = null;
        // It is valid for To date to be empty
        if (timePeriodType.getEndPosition().getValue().size() > 0) {
            toDate = GMLDateUtils.stringToDateMultiParsers(timePeriodType.getEndPosition().getValue().get(0));
        }

        EffectiveDates ed = new EffectiveDates();

        ed.setFrom(fromDate);
        ed.setTo(toDate);
        return ed;
    }

    @Override
    public TimePeriodType convertFrom(EffectiveDates effectiveDates, Type<TimePeriodType> type, MappingContext mappingContext) {
        TimePositionType beginPosition = new TimePositionType();
        TimePositionType endPosition = new TimePositionType();
        beginPosition.setValue(Stream.of(GMLDateUtils.dateToString(effectiveDates.getFrom(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_SEC)).collect(Collectors.toList()));
        // It is valid for To date to be empty - return empty list
        List<String> toDates = new ArrayList<>();
        if (effectiveDates.getTo() != null) {
            toDates = Stream.of(GMLDateUtils.dateToString(effectiveDates.getTo(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_SEC)).collect(Collectors.toList());
        }
        endPosition.setValue(toDates);

        TimePeriodType tpt = new TimePeriodType();
        tpt.setBeginPosition(beginPosition);
        tpt.setEndPosition(endPosition);

        return tpt;
    }
}
