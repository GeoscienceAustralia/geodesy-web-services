package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.domain.model.sitelog.SignalObstructionLogItem;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLMarshaller;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLUtils;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.marshalling.moxy.GeodesyMLMoxy;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;
import au.gov.xml.icsm.geodesyml.v_0_4.BasePossibleProblemSourceType;
import au.gov.xml.icsm.geodesyml.v_0_4.GeodesyMLType;
import au.gov.xml.icsm.geodesyml.v_0_4.SiteLogType;
import net.opengis.gml.v_3_2_1.TimePeriodType;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

/**
 * Tests the mapping of a GeodesyML SignalObstructionsPropertyType element
 * to and from an SignalObstructionLogItem domain object.
 */
public class SignalObstructionMapperTest {

    private SignalObstructionMapper mapper = new SignalObstructionMapper();
    private GeodesyMLMarshaller marshaller = new GeodesyMLMoxy();

    @Test
    public void testMapping() throws Exception {

        GeodesyMLType mobs = marshaller.unmarshal(TestResources.customGeodesyMLSiteLogReader("METZ-signalObstructions"), GeodesyMLType.class)
                .getValue();

        SiteLogType siteLog = GeodesyMLUtils.getElementFromJAXBElements(mobs.getElements(), SiteLogType.class)
                .findFirst().get();

        BasePossibleProblemSourceType signalObstructionTypeA =
                siteLog.getSignalObstructions().get(0).getSignalObstruction();

        SignalObstructionLogItem logItem = mapper.to(signalObstructionTypeA);
        assertThat(logItem.getPossibleProblemSource(), equalTo(signalObstructionTypeA.getPossibleProblemSource()));
        String xmlEffectiveDateFrom = ((TimePeriodType) signalObstructionTypeA.getValidTime().getAbstractTimePrimitive().getValue())
                .getBeginPosition().getValue().get(0);
        assertThat(GMLDateUtils.dateToString(logItem.getEffectiveDates().getFrom(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_MILLISEC),
            equalTo(GMLDateUtils.stringToDateToStringMultiParsers(xmlEffectiveDateFrom)));
        String xmlEffectiveDateTo = ((TimePeriodType) signalObstructionTypeA.getValidTime().getAbstractTimePrimitive().getValue())
                .getEndPosition().getValue().get(0);
        assertThat(GMLDateUtils.dateToString(logItem.getEffectiveDates().getTo(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_MILLISEC),
            equalTo(GMLDateUtils.stringToDateToStringMultiParsers(xmlEffectiveDateTo)));
        assertThat(logItem.getNotes(), equalTo(signalObstructionTypeA.getNotes()));

        BasePossibleProblemSourceType signalObstructionTypeB = mapper.from(logItem);
        assertThat(signalObstructionTypeB.getPossibleProblemSource(), equalTo(logItem.getPossibleProblemSource()));
        xmlEffectiveDateFrom = ((TimePeriodType) signalObstructionTypeB.getValidTime().getAbstractTimePrimitive().getValue())
                .getBeginPosition().getValue().get(0);
        assertThat(
                GMLDateUtils.stringToDateToStringMultiParsers(xmlEffectiveDateFrom),
            equalTo(GMLDateUtils.dateToString(logItem.getEffectiveDates().getFrom(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_MILLISEC)));
        xmlEffectiveDateTo = ((TimePeriodType) signalObstructionTypeB.getValidTime().getAbstractTimePrimitive().getValue())
                .getEndPosition().getValue().get(0);
        assertThat(
                GMLDateUtils.stringToDateToStringMultiParsers(xmlEffectiveDateTo),
            equalTo(GMLDateUtils.dateToString(logItem.getEffectiveDates().getTo(), GMLDateUtils.GEODESYML_DATE_FORMAT_TIME_MILLISEC)));
        assertThat(signalObstructionTypeB.getPossibleProblemSource(), equalTo(logItem.getPossibleProblemSource()));

    }

}

