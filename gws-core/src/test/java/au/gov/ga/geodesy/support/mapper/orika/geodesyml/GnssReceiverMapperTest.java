package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.domain.model.sitelog.GnssReceiverLogItem;
import au.gov.ga.geodesy.support.spring.UnitTest;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;
import au.gov.xml.icsm.geodesyml.v_0_5.GnssReceiverType;
import au.gov.xml.icsm.geodesyml.v_0_5.IgsReceiverModelCodeType;

import net.opengis.gml.v_3_2_1.CodeType;
import net.opengis.gml.v_3_2_1.TimePositionType;

public class GnssReceiverMapperTest extends UnitTest {

    @Autowired
    private GnssReceiverMapper mapper;

    @Test
    public void testMappingToLogItem() {
        String dateInstalled = "2012-03-24T02:03:23.000Z";

        GnssReceiverType receiver = new GnssReceiverType()
            .withIgsModelCode((IgsReceiverModelCodeType) new IgsReceiverModelCodeType()
                .withCodeSpace("https://igscb.jpl.nasa.gov/igscb/station/general/rcvr_ant.tab")
                .withCodeList("http://xml.gov.au/icsm/geodesyml/codelists/antenna-receiver-codelists.xml#GeodesyML_GNSSReceiverTypeCode")
                .withCodeListValue("LEICA GRX1200GGPRO")
                .withValue("LEICA GRX1200GGPRO")
            )
            .withNotes("test notes")
            .withSatelliteSystem(Arrays.asList(
                new CodeType().withValue("GPS").withCodeSpace("eGeodesy/satelliteSystem"),
                new CodeType().withValue("Galileo").withCodeSpace("eGeodesy/satelliteSystem")
            ))
            .withFirmwareVersion("1.2")
            .withManufacturerSerialNumber("123")
            .withElevationCutoffSetting(4.0)
            .withDateInstalled(timePosition(dateInstalled));

        GnssReceiverLogItem logItem = mapper.to(receiver);
        assertThat(logItem.getType(), equalTo(receiver.getIgsModelCode().getCodeListValue()));
        assertThat(logItem.getFirmwareVersion(), equalTo(receiver.getFirmwareVersion()));
        assertThat(logItem.getSerialNumber(), equalTo(receiver.getManufacturerSerialNumber()));
        assertThat(logItem.getElevationCutoffSetting(), equalTo(String.valueOf(receiver.getElevationCutoffSetting())));
        assertThat(logItem.getSatelliteSystem(), equalTo("GPS,Galileo"));
        assertThat(logItem.getDateInstalled(), equalTo(GMLDateUtils.stringToDateMultiParsers(receiver.getDateInstalled().getValue().get
            (0))));
        assertThat(logItem.getEffectiveDates().getFrom(),equalTo( GMLDateUtils.stringToDateMultiParsers(receiver.getDateInstalled()
            .getValue().get(0))));
        assertThat(logItem.getNotes(), equalTo(receiver.getNotes()));
        
        GnssReceiverType receiverB = mapper.from(logItem);
        assertThat(receiverB.getIgsModelCode().getCodeSpace(), equalTo("https://igscb.jpl.nasa.gov/igscb/station/general/rcvr_ant.tab"));
        assertThat(receiverB.getIgsModelCode().getCodeList(), equalTo("http://xml.gov" +
            ".au/icsm/geodesyml/codelists/antenna-receiver-codelists.xml#GeodesyML_GNSSReceiverTypeCode"));
        assertThat(receiverB.getIgsModelCode().getCodeListValue(), equalTo("LEICA GRX1200GGPRO"));
        assertThat(receiverB.getIgsModelCode().getValue(), equalTo("LEICA GRX1200GGPRO"));
        assertThat(receiverB.getFirmwareVersion(), equalTo(logItem.getFirmwareVersion()));
        assertThat(receiverB.getManufacturerSerialNumber(), equalTo(logItem.getSerialNumber()));
        assertThat(receiverB.getElevationCutoffSetting(), equalTo(Double.parseDouble(logItem.getElevationCutoffSetting())));
        assertThat(receiverB.getSatelliteSystem(), equalTo(receiver.getSatelliteSystem()));
        assertThat(GMLDateUtils.stringToDateMultiParsers(receiverB.getDateInstalled().getValue().get(0)), equalTo(logItem
            .getDateInstalled()));
        assertThat(logItem.getEffectiveDates().getFrom(), equalTo(GMLDateUtils.stringToDateMultiParsers(receiverB.getDateInstalled()
            .getValue().get(0))));
        assertThat(receiverB.getNotes(), equalTo(logItem.getNotes()));
    }

    private TimePositionType timePosition(String date) {
        TimePositionType timePosition = new TimePositionType();
        timePosition.getValue().add(date);
        return timePosition;
    }
}

