package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.domain.model.sitelog.RadioInterference;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLMarshaller;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLUtils;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.marshalling.moxy.GeodesyMLMoxy;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;
import au.gov.ga.geodesy.support.utils.MappingDirection;
import au.gov.ga.geodesy.support.utils.ToFromDate;
import au.gov.xml.icsm.geodesyml.v_0_3.GeodesyMLType;
import au.gov.xml.icsm.geodesyml.v_0_3.RadioInterferencesType;
import au.gov.xml.icsm.geodesyml.v_0_3.SiteLogType;
import net.opengis.gml.v_3_2_1.TimePeriodType;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * Tests the mapping of a GeodesyML humiditySensor element
 * to and from a HumiditySensorLogItem domain object.
 */
public class RadioInterferenceMapperTest {

    private RadioInterferenceMapper mapper = new RadioInterferenceMapper();
    private GeodesyMLMarshaller marshaller = new GeodesyMLMoxy();
    private DateTimeFormatter format = dateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");

    /**
     * Test when the RadioInterference.effectiveDates has a from AND to date
     *
     * @throws Exception
     */
    @Test
    public void testMappingWithoutToDate() throws Exception {

        GeodesyMLType mobs = marshaller.unmarshal(TestResources.geodesyMLTestDataSiteLogReader("IRKJ_RadioInterference_NoToDate"), GeodesyMLType.class)
                .getValue();

        SiteLogType logItem = GeodesyMLUtils.getElementFromJAXBElements(mobs.getElements(), SiteLogType.class)
                .findFirst().get();

        RadioInterferencesType radioInterferencesDTO = logItem.getRadioInterferencesSet().get(0).getRadioInterferences();

        RadioInterference radioInterferenceEntity = mapper.to(radioInterferencesDTO);

        assertCommon(radioInterferencesDTO, radioInterferenceEntity, MappingDirection.FROM_DTO_TO_ENTITY);

        // IRKJ_RadioInterference_NoToDate has no end/to date
        Assert.assertEquals(((TimePeriodType) radioInterferencesDTO.getValidTime().getAbstractTimePrimitive().getValue()).getEndPosition().getValue().size(), 0);
        Assert.assertNull(radioInterferenceEntity.getEffectiveDates().getTo());

        // <----> Test after mapping back the other way
        RadioInterferencesType radioInterferencesDTO2 = mapper.from(radioInterferenceEntity);

        assertCommon(radioInterferencesDTO, radioInterferenceEntity, MappingDirection.FROM_ENTITY_TO_DTO);

        // IRKJ_RadioInterference_NoToDate has no end/to date
        Assert.assertEquals(((TimePeriodType) radioInterferencesDTO2.getValidTime().getAbstractTimePrimitive().getValue()).getEndPosition().getValue().size(), 0);
    }

    /**
     * Test when the RadioInterference.effectiveDates has a from AND to date
     *
     * @throws Exception
     */
    @Test
    public void testMappingWithToDate() throws Exception {
        DateTimeFormatter format = dateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");

        GeodesyMLType mobs = marshaller.unmarshal(TestResources.geodesyMLTestDataSiteLogReader("IRKJ_RadioInterference_WithToDate"), GeodesyMLType.class)
                .getValue();

        SiteLogType logItem = GeodesyMLUtils.getElementFromJAXBElements(mobs.getElements(), SiteLogType.class)
                .findFirst().get();

        RadioInterferencesType radioInterferencesDTO = logItem.getRadioInterferencesSet().get(0).getRadioInterferences();

        RadioInterference radioInterferenceEntity = mapper.to(radioInterferencesDTO);

        assertCommon(radioInterferencesDTO, radioInterferenceEntity, MappingDirection.FROM_DTO_TO_ENTITY);

        // IRKJ_RadioInterference_WithToDate has an end/to date
        String fromDateString = ((TimePeriodType) radioInterferencesDTO.getValidTime().getAbstractTimePrimitive().getValue()).getBeginPosition().getValue().get(0);
        String fromDateFormatted = GMLDateUtils.stringToDateToString(fromDateString, format);
        Assert.assertEquals(format.format(radioInterferenceEntity.getEffectiveDates().getFrom()), fromDateFormatted);

        // <----> Test after mapping back the other way
        RadioInterferencesType radioInterferencesDTO2 = mapper.from(radioInterferenceEntity);

        assertCommon(radioInterferencesDTO, radioInterferenceEntity, MappingDirection.FROM_ENTITY_TO_DTO);

        // IRKJ_RadioInterference_WithToDate has an end/to date

        String actualToDateFormatted = getDTODateFormattedAsString(radioInterferencesDTO2, ToFromDate.TO_DATE);
        String expectedToDateFormatted = getEntityDateFormattedAsString(radioInterferenceEntity, ToFromDate.TO_DATE);
        Assert.assertEquals(actualToDateFormatted, expectedToDateFormatted);
    }

    private void assertCommon(RadioInterferencesType radioInterferencesDTO, RadioInterference radioInterferenceEntity, MappingDirection mappingDirection) {
        if (mappingDirection == MappingDirection.FROM_DTO_TO_ENTITY) {
            Assert.assertEquals(radioInterferenceEntity.getNotes(), radioInterferencesDTO.getNotes());
            Assert.assertEquals(radioInterferenceEntity.getObservedDegradation(), radioInterferencesDTO.getObservedDegradations());
            Assert.assertEquals(radioInterferenceEntity.getPossibleProblemSource(), radioInterferencesDTO.getPossibleProblemSources());

            // From Date
            String expectedFromDateFormatted = getDTODateFormattedAsString(radioInterferencesDTO, ToFromDate.FROM_DATE);
            String actualFromDateFormatted = getEntityDateFormattedAsString(radioInterferenceEntity, ToFromDate.FROM_DATE);
            Assert.assertEquals(actualFromDateFormatted, expectedFromDateFormatted);
        } else {
            Assert.assertEquals(radioInterferencesDTO.getNotes(), radioInterferencesDTO.getNotes());
            Assert.assertEquals(radioInterferencesDTO.getObservedDegradations(), radioInterferencesDTO.getObservedDegradations());
            Assert.assertEquals(radioInterferencesDTO.getPossibleProblemSources(), radioInterferencesDTO.getPossibleProblemSources());

            // From Date
            String expectedFromDateFormatted = format.format(radioInterferenceEntity.getEffectiveDates().getFrom());
            String actualFromDateString = ((TimePeriodType) radioInterferencesDTO.getValidTime().getAbstractTimePrimitive().getValue()).getBeginPosition().getValue().get(0);
            String actualFromDateFormatted = GMLDateUtils.stringToDateToString(actualFromDateString, format);
            Assert.assertEquals(expectedFromDateFormatted, actualFromDateFormatted);
        }
    }

    /**
     * @param radioInterferenceEntity
     * @param toFromDate
     * @return date as string extracted from the given Entity object and format using the internal format being used
     */
    private String getEntityDateFormattedAsString(RadioInterference radioInterferenceEntity, ToFromDate toFromDate) {
        String dateFormatted = null;
        if (toFromDate == ToFromDate.FROM_DATE) {
            dateFormatted = format.format(radioInterferenceEntity.getEffectiveDates().getFrom());
        } else {
            dateFormatted = format.format(radioInterferenceEntity.getEffectiveDates().getTo());
        }
        return dateFormatted;
    }

    /**
     * Use date intermediate to guarantee success (ie. no formatting errors)
     *
     * @param radioInterferencesDTO
     * @return date as string extracted from the DTO object and format using the internal format being used
     */
    private String getDTODateFormattedAsString(RadioInterferencesType radioInterferencesDTO, ToFromDate toFromDate) {
        String dateFormattedString = null;

        if (toFromDate == ToFromDate.FROM_DATE) {
            dateFormattedString = ((TimePeriodType) radioInterferencesDTO.getValidTime().getAbstractTimePrimitive().getValue()).getBeginPosition().getValue().get(0);
        } else {
            dateFormattedString = ((TimePeriodType) radioInterferencesDTO.getValidTime().getAbstractTimePrimitive().getValue()).getEndPosition().getValue().get(0);
        }
        Instant intermediateDate = GMLDateUtils.stringToDateMultiParsers(dateFormattedString);
        String dateFormatted = GMLDateUtils.dateToString(intermediateDate, format);
        return dateFormatted;
    }

    private DateTimeFormatter dateFormat(String pattern) {
        return DateTimeFormatter.ofPattern(pattern).withZone(ZoneId.of("UTC"));
    }

}
