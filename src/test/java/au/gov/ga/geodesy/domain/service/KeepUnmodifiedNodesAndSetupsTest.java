package au.gov.ga.geodesy.domain.service;

import static org.testng.Assert.assertEquals;

import java.io.File;
import java.io.FileReader;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.domain.model.CorsSiteRepository;
import au.gov.ga.geodesy.domain.model.NodeRepository;
import au.gov.ga.geodesy.domain.model.SetupRepository;
import au.gov.ga.geodesy.domain.model.SynchronousEventPublisher;
import au.gov.ga.geodesy.domain.model.equipment.EquipmentFactory;
import au.gov.ga.geodesy.domain.model.equipment.EquipmentRepository;
import au.gov.ga.geodesy.domain.model.event.EventSubscriber;
import au.gov.ga.geodesy.domain.model.event.SiteLogReceived;
import au.gov.ga.geodesy.domain.model.event.SiteUpdated;
import au.gov.ga.geodesy.igssitelog.support.marshalling.moxy.IgsSiteLogMoxyMarshaller;
import au.gov.ga.geodesy.port.SiteLogReader;
import au.gov.ga.geodesy.port.adapter.sopac.SiteLogSopacReader;
import au.gov.ga.geodesy.support.mapper.orika.SiteLogOrikaMapper;
import au.gov.ga.geodesy.support.spring.PersistenceJpaConfig;
import au.gov.ga.geodesy.support.spring.TestAppConfig;

@ContextConfiguration(classes = {TestAppConfig.class, IgsSiteLogMoxyMarshaller.class, IgsSiteLogService.class,
        SiteLogSopacReader.class, SiteLogOrikaMapper.class, EquipmentFactory.class, CorsSiteService.class,
        NodeService.class, SynchronousEventPublisher.class,
        PersistenceJpaConfig.class}, loader = AnnotationConfigContextLoader.class)
@Transactional("geodesyTransactionManager")
public class KeepUnmodifiedNodesAndSetupsTest extends AbstractTransactionalTestNGSpringContextTests {

    private static final String siteLogsDir = "src/test/resources/sitelog/";

    private static final String fourCharId = "ABRK";

    @Autowired
    private CorsSiteRepository sites;

    // This isn't used directly in here but is necessary for the test
    @Autowired
    @Qualifier("CorsSiteService")
    // private CorsSiteService siteService;
    private EventSubscriber<SiteLogReceived> siteService;

    @Autowired
    private IgsSiteLogService siteLogService;

    @Autowired
    private SetupRepository setups;

    @Autowired
    private NodeRepository nodes;

    @Autowired
    private EquipmentRepository equipment;

    @Autowired
    private PlatformTransactionManager txnManager;

    @Autowired
    private SiteLogReader siteLogSource;

    // This isn't used directly in here but is necessary for the test
    @Autowired
    @Qualifier("NodeService")
    // private NodeService nodeService;
    private EventSubscriber<SiteUpdated> nodeService;

    private abstract class InTransaction {
        public void f() throws Exception {
            DefaultTransactionDefinition txnDef = new DefaultTransactionDefinition();
            TransactionStatus txn = txnManager.getTransaction(txnDef);
            try {
                f();
            } finally {
                txnManager.commit(txn);
            }
        }
    }

    private InTransaction uploadABRK = new InTransaction() {
        public void f() throws Exception {
            siteLogSource.setSiteLogReader(new FileReader(new File(siteLogsDir + fourCharId + ".xml")));
            siteLogService.upload(siteLogSource.getSiteLog());
        }
    };
    private InTransaction[] scenario = {uploadABRK, uploadABRK,};

    private void execute(InTransaction... scenario) throws Exception {
        for (InTransaction s : scenario) {
            s.f();
        }
    }

    @Test
    @Rollback(false)
    public void execute() throws Exception {
        execute(scenario);
    }

    @Test(dependsOnMethods = "execute")
    @Rollback(false)
    public void checkSetupId() throws Exception {
        assertEquals(sites.count(), 1);
        assertEquals(setups.count(), 1);
        assertEquals(nodes.count(), 1);
        assertEquals(equipment.count(), 3);
    }
}
