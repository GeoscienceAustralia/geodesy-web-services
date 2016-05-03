package au.gov.ga.geodesy.domain.service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.transaction.annotation.Transactional;
import org.testng.Assert;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.domain.model.SynchronousEventPublisher;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;
import au.gov.ga.geodesy.igssitelog.support.marshalling.moxy.IgsSiteLogMoxyMarshaller;
import au.gov.ga.geodesy.port.InvalidSiteLogException;
import au.gov.ga.geodesy.port.SiteLogReader;
import au.gov.ga.geodesy.port.adapter.sopac.SiteLogSopacReader;
import au.gov.ga.geodesy.support.mapper.orika.SiteLogOrikaMapper;
import au.gov.ga.geodesy.support.spring.PersistenceJpaConfig;
import au.gov.ga.geodesy.support.spring.TestAppConfig;

@ContextConfiguration(classes = {TestAppConfig.class, IgsSiteLogService.class, SiteLogRepository.class,
        SiteLogSopacReader.class, IgsSiteLogMoxyMarshaller.class, SiteLogOrikaMapper.class,
        SynchronousEventPublisher.class, PersistenceJpaConfig.class}, loader = AnnotationConfigContextLoader.class)

@Transactional("geodesyTransactionManager")
public class ChangeReceiverAtABRKTest extends AbstractTransactionalTestNGSpringContextTests {

    private static final String scenarioDirName = "src/test/resources/change-receiver-at-abrk/";

    @Autowired
    private IgsSiteLogService siteLogService;

    @Autowired
    private SiteLogRepository siteLogs;

    @Autowired
    private SiteLogReader siteLogSource;

    private void executeSiteLogScenario(String scenarioDirName) throws FileNotFoundException, InvalidSiteLogException {
        File[] siteLogFiles = new File(scenarioDirName).listFiles((File dir, String f) -> {
            return f.endsWith(".xml");
        });
        for (File siteLogFile : siteLogFiles) {
            siteLogSource.setSiteLogReader(new FileReader(siteLogFile));
            siteLogService.upload(siteLogSource.getSiteLog());
        }
    }

    @Test
    @Rollback(false)
    public void checkSetupId() throws Exception {
        Assert.assertEquals(0, siteLogs.count());
        executeSiteLogScenario(scenarioDirName);
        Assert.assertEquals(1, siteLogs.count());
    }
}
