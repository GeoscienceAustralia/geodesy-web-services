package au.gov.ga.geodesy.domain.service;

import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.transaction.annotation.Transactional;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.domain.model.MockEventPublisher;
import au.gov.ga.geodesy.domain.model.event.Event;
import au.gov.ga.geodesy.domain.model.event.EventPublisher;
import au.gov.ga.geodesy.domain.model.event.SiteLogReceived;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;
import au.gov.ga.geodesy.igssitelog.support.marshalling.moxy.IgsSiteLogMoxyMarshaller;
import au.gov.ga.geodesy.port.SiteLogReader;
import au.gov.ga.geodesy.port.adapter.sopac.SiteLogSopacReader;
import au.gov.ga.geodesy.support.mapper.orika.SiteLogOrikaMapper;
import au.gov.ga.geodesy.support.spring.PersistenceJpaConfig;
import au.gov.ga.geodesy.support.spring.TestAppConfig;

@ContextConfiguration(classes = {TestAppConfig.class, IgsSiteLogService.class, SiteLogSopacReader.class,
        SiteLogOrikaMapper.class, IgsSiteLogMoxyMarshaller.class, MockEventPublisher.class,
        PersistenceJpaConfig.class}, loader = AnnotationConfigContextLoader.class)

@Transactional("geodesyTransactionManager")
public class UploadAllSiteLogsTest extends AbstractTransactionalTestNGSpringContextTests {

    private static final String siteLogsDir = "src/test/resources/sitelog/";
    private File[] siteLogFiles = null;

    @Autowired
    private IgsSiteLogService service;

    @Autowired
    private SiteLogRepository siteLogs;

    @Autowired
    // @Qualifier("MockEventPublisher")
    public EventPublisher eventPublisher;

    @Autowired
    private SiteLogReader siteLogSource;

    @BeforeClass
    private void setup() throws Exception {
        siteLogFiles = new File(siteLogsDir).listFiles(new FileFilter() {
            public boolean accept(File f) {
                return f.getName().startsWith("A") && f.getName().endsWith(".xml");
                /* return f.getName().endsWith(".xml"); */
            }
        });
    }

    @Test
    @Rollback(false)
    public void upload() throws Exception {
        for (File f : siteLogFiles) {
            siteLogSource.setSiteLogReader(new FileReader(f));
            service.upload(siteLogSource.getSiteLog());
        }
    }

    @Test(dependsOnMethods = {"upload"})
    public void check() throws Exception {
        List<Event> events = ((MockEventPublisher) eventPublisher).getPublishedEvents();
        Assert.assertEquals(events.size(), 34);
        for (Event e : events) {
            Assert.assertTrue(e instanceof SiteLogReceived);
        }
        Assert.assertEquals(34, siteLogs.count());
    }
}
