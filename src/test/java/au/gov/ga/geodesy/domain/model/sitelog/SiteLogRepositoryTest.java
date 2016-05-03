package au.gov.ga.geodesy.domain.model.sitelog;

import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.transaction.annotation.Transactional;
import org.testng.Assert;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.igssitelog.support.marshalling.moxy.IgsSiteLogMoxyMarshaller;
import au.gov.ga.geodesy.port.adapter.sopac.SiteLogSopacReader;
import au.gov.ga.geodesy.support.mapper.orika.SiteLogOrikaMapper;
import au.gov.ga.geodesy.support.spring.PersistenceJpaConfig;
import au.gov.ga.geodesy.support.spring.TestAppConfig;

@ContextConfiguration(classes = {TestAppConfig.class, PersistenceJpaConfig.class, SiteLogSopacReader.class,
        SiteLogRepository.class, IgsSiteLogMoxyMarshaller.class,
        SiteLogOrikaMapper.class}, loader = AnnotationConfigContextLoader.class)

@Transactional("geodesyTransactionManager")
public class SiteLogRepositoryTest extends AbstractTransactionalTestNGSpringContextTests {

    private static final Logger log = LoggerFactory.getLogger(SiteLogRepositoryTest.class);

    @Autowired
    private SiteLogRepository igsSiteLogs;

    @Autowired
    private SiteLogSopacReader siteLogSource;

    private static final String sampleSiteLogsDir = "src/test/resources/sitelog";

    @Test(groups = "first")
    @Rollback(false)
    public void saveALIC() throws Exception {
        File alic = new File(sampleSiteLogsDir + "/ALIC.xml");
        siteLogSource.setSiteLogReader(new InputStreamReader(new FileInputStream(alic)));
        igsSiteLogs.saveAndFlush(siteLogSource.getSiteLog());
    }

    /**
     * BZGN is a special case, because it does not have contact telephone numbers.
     */
    @Test(groups = "first")
    @Rollback(false)
    public void saveBZGN() throws Exception {
        File alic = new File(sampleSiteLogsDir + "/BZGN.xml");
        siteLogSource.setSiteLogReader(new InputStreamReader(new FileInputStream(alic)));
        igsSiteLogs.saveAndFlush(siteLogSource.getSiteLog());
    }

    @Test(dependsOnGroups = "first")
    @Rollback(false)
    public void saveAllSiteLogs() throws Exception {
        igsSiteLogs.deleteAll();
        for (File f : getSiteLogFiles()) {
            log.info("Saving " + f.getName());
            siteLogSource.setSiteLogReader(new InputStreamReader(new FileInputStream(f)));
            igsSiteLogs.saveAndFlush(siteLogSource.getSiteLog());
        }
    }

    @Test(dependsOnMethods = {"saveAllSiteLogs"})
    @Rollback(false)
    public void checkNumberOfSavedSiteLogs() throws Exception {
        Assert.assertEquals(igsSiteLogs.count(), 681);
    }

    @Test(dependsOnMethods = {"saveAllSiteLogs"})
    @Rollback(false)
    public void deleteSavedLogs() {
        igsSiteLogs.deleteAll();
    }

    @Test(dependsOnMethods = {"deleteSavedLogs"})
    @Rollback(false)
    public void checkNumberOfDeleteSiteLogs() throws Exception {
        Assert.assertEquals(igsSiteLogs.count(), 0);
    }

    private File[] getSiteLogFiles() throws Exception {
        return new File(sampleSiteLogsDir).listFiles(new FileFilter() {
            public boolean accept(File f) {
                return f.getName().endsWith(".xml");
            }
        });
    }
}
