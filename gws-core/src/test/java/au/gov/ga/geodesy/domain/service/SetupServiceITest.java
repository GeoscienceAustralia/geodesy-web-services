package au.gov.ga.geodesy.domain.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsNull.nullValue;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;
import org.testng.annotations.Test;

import com.google.common.collect.Iterators;
import com.querydsl.core.types.Predicate;

import au.gov.ga.geodesy.domain.model.CorsSiteRepository;
import au.gov.ga.geodesy.domain.model.EquipmentInUse;
import au.gov.ga.geodesy.domain.model.QSetup;
import au.gov.ga.geodesy.domain.model.Setup;
import au.gov.ga.geodesy.domain.model.SetupRepository;
import au.gov.ga.geodesy.domain.model.SetupType;
import au.gov.ga.geodesy.domain.model.equipment.Clock;
import au.gov.ga.geodesy.domain.model.equipment.ClockConfiguration;
import au.gov.ga.geodesy.domain.model.equipment.EquipmentConfigurationRepository;
import au.gov.ga.geodesy.domain.model.equipment.EquipmentRepository;
import au.gov.ga.geodesy.domain.model.equipment.GnssAntenna;
import au.gov.ga.geodesy.domain.model.equipment.GnssAntennaConfiguration;
import au.gov.ga.geodesy.domain.model.equipment.GnssReceiver;
import au.gov.ga.geodesy.domain.model.equipment.GnssReceiverConfiguration;
import au.gov.ga.geodesy.port.SiteLogReader;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

@Transactional("geodesyTransactionManager")
public class SetupServiceITest extends IntegrationTest {

    @Autowired
    private SetupService setupService;

    @Autowired
    private CorsSiteLogService siteLogService;

    @Autowired
    private CorsSiteRepository sites;

    @Autowired
    private SetupRepository setups;

    @Autowired
    private EquipmentConfigurationRepository equipmentConfigurations;

    @Autowired
    private EquipmentRepository equipment;

    @Test
    @Rollback(false)
    public void saveIncompleteSetups() throws Exception {
        SiteLogReader bath = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("BATH-incomplete-setups"));
        siteLogService.upload(bath.getSiteLog());
    }

    @Test(dependsOnMethods = {"saveIncompleteSetups"})
    @Rollback(false)
    public void checkIncompleteSetups() throws Exception {
        List<Setup> corsSetups = setups.findBySiteId(
            sites.findByFourCharacterId("BATH").getId(),
            SetupType.CorsSetup
        );

        assertThat(corsSetups.size(), is(7));

        // Check setup 0
        {
            Setup setup = corsSetups.get(0);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-02")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-03")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(1));

            checkAntenna(equipmentInUse.get(0), "A0", "0.0");
        }

        // Check setup 1
        {
            Setup setup = corsSetups.get(1);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-03")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-04")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkAntenna(equipmentInUse.get(0), "A0", "0.0");
            checkReceiver(equipmentInUse.get(1), "R0", "R0-F1");
        }

        // Check setup 2
        {
            Setup setup = corsSetups.get(2);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-04")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-05")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkAntenna(equipmentInUse.get(0), "A0", "0.0");
            checkReceiver(equipmentInUse.get(1), "R1", "R1-F0");
        }

        // Check setup 3
        {
            Setup setup = corsSetups.get(3);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-05")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-06")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "1.0");
        }

        // Check setup 4
        {
            Setup setup = corsSetups.get(4);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-06")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-07")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(3));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "1.0");
            checkAntenna(equipmentInUse.get(2), "A1", "0.0");
        }

        // Check setup 5
        {
            Setup setup = corsSetups.get(5);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-07")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-08")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(4));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "1.0");
            checkAntenna(equipmentInUse.get(2), "A1", "0.0");
            checkClock(equipmentInUse.get(3), "EXTERNAL CESIUM", "5.0");
        }

        // Check setup 6
        {
            Setup setup = corsSetups.get(6);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-08")));
            assertThat(setup.getEffectivePeriod().getTo(),   nullValue());

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(3));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "1.0");
            checkAntenna(equipmentInUse.get(2), "A1", "0.0");
        }
    }

    @Test(dependsOnMethods = "checkIncompleteSetups")
    @Rollback(false)
    public void saveCompleteSetups() throws Exception {
        SiteLogReader bath = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("BATH-complete-setups"));
        siteLogService.upload(bath.getSiteLog());
    }

    @Test(dependsOnMethods = "saveCompleteSetups")
    @Rollback(false)
    public void checkCompleteSetups() throws Exception {
        List<Setup> corsSetups = setups.findBySiteId(
            sites.findByFourCharacterId("BATH").getId(),
            SetupType.CorsSetup
        );

        assertThat(corsSetups.size(), is(8));

        // Check setup 0
        {
            Setup setup = corsSetups.get(0);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-01")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-02")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(1));

            checkReceiver(equipmentInUse.get(0), "R0", "R0-F0");
        }

        // Check setup 1
        {
            Setup setup = corsSetups.get(1);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-02")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-03")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkReceiver(equipmentInUse.get(0), "R0", "R0-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "0.0");
        }

        // Check setup 2
        {
            Setup setup = corsSetups.get(2);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-03")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-04")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkAntenna(equipmentInUse.get(0), "A0", "0.0");
            checkReceiver(equipmentInUse.get(1), "R0", "R0-F1");
        }

        // Check setup 3
        {
            Setup setup = corsSetups.get(3);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-04")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-05")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkAntenna(equipmentInUse.get(0), "A0", "0.0");
            checkReceiver(equipmentInUse.get(1), "R1", "R1-F0");
        }

        // Check setup 4
        {
            Setup setup = corsSetups.get(4);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-05")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-06")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A0", "1.0");
        }

        // Check setup 5
        {
            Setup setup = corsSetups.get(5);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-06")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-07")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A1", "0.0");
        }

        // Check setup 6
        {
            Setup setup = corsSetups.get(6);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-07")));
            assertThat(setup.getEffectivePeriod().getTo(),   is(parseInstant("2000-01-08")));

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(3));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A1", "0.0");
            checkClock(equipmentInUse.get(2), "EXTERNAL CESIUM", "5.0");
        }

        // Check setup 7
        {
            Setup setup = corsSetups.get(7);
            assertThat(setup.getEffectivePeriod().getFrom(), is(parseInstant("2000-01-08")));
            assertThat(setup.getEffectivePeriod().getTo(),   nullValue());

            List<EquipmentInUse> equipmentInUse = setup.getEquipmentInUse();
            assertThat(equipmentInUse.size(), is(2));

            checkReceiver(equipmentInUse.get(0), "R1", "R1-F0");
            checkAntenna(equipmentInUse.get(1), "A1", "0.0");
        }
    }

    @Test(dependsOnMethods = "checkCompleteSetups")
    @Rollback(false)
    public void regenerateSetups() throws Exception {
        setupService.deleteSetups();
        assertThat(setups.count(), is(0L));
        assertThat(equipment.count(), is(0L));
        assertThat(equipmentConfigurations.count(), is(0L));
        setupService.createSetups();
    }

    @Test(dependsOnMethods = {"regenerateSetups"})
    @Rollback(false)
    public void checkRegeneratedSetups() throws Exception {
        Predicate isCorsSetup = QSetup.setup.type.eq(SetupType.CorsSetup);
        assertThat(
            Iterators.size(setups.findAll(isCorsSetup).iterator()),
            is(8)
        );
    }

    private Instant parseInstant(String date) {
        return LocalDate.parse(date).atStartOfDay(ZoneId.of("UTC")).toInstant();
    }

    private void checkReceiver(EquipmentInUse inUse, String serialNumber, String firmwareVersion) {
        GnssReceiver receiver = (GnssReceiver) equipment.findOne(inUse.getEquipmentId());

        GnssReceiverConfiguration configuration =
            (GnssReceiverConfiguration) equipmentConfigurations.findOne(inUse.getConfigurationId());

        assertThat(receiver.getSerialNumber(), is(serialNumber));
        assertThat(configuration.getFirmwareVersion(), is(firmwareVersion));
    }

    private void checkAntenna(EquipmentInUse inUse, String serialNumber, String alignmentFromTrueNorth) {
        GnssAntenna antenna = (GnssAntenna) equipment.findOne(inUse.getEquipmentId());

        GnssAntennaConfiguration configuration =
            (GnssAntennaConfiguration) equipmentConfigurations.findOne(inUse.getConfigurationId());

        assertThat(antenna.getSerialNumber(), is(serialNumber));
        assertThat(configuration.getAlignmentFromTrueNorth(), is(alignmentFromTrueNorth));
    }

    private void checkClock(EquipmentInUse inUse, String type, String frequency) {
        Clock clock = (Clock) equipment.findOne(inUse.getEquipmentId());
        assertThat(clock.getType(), is(type));

        ClockConfiguration configuration =
            (ClockConfiguration) equipmentConfigurations.findOne(inUse.getConfigurationId());

        assertThat(configuration.getInputFrequency(), is(frequency));
    }
}
