package au.gov.ga.geodesy.interfaces.rest;

import java.io.File;
import java.nio.file.DirectoryIteratorException;
import java.nio.file.DirectoryStream;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.test.context.web.AnnotationConfigWebContextLoader;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;
import org.testng.annotations.BeforeClass;

import au.gov.ga.geodesy.support.spring.GeodesyRepositoryRestMvcConfig;
import au.gov.ga.geodesy.support.spring.GeodesyRestMvcConfig;
import au.gov.ga.geodesy.support.spring.GeodesyServiceTestConfig;
import au.gov.ga.geodesy.support.spring.PersistenceJpaConfig;

@ContextConfiguration(
        classes = {
            GeodesyServiceTestConfig.class,
            GeodesyRepositoryRestMvcConfig.class,
            GeodesyRestMvcConfig.class,
            PersistenceJpaConfig.class
        },
        loader = AnnotationConfigWebContextLoader.class)

@WebAppConfiguration
@Transactional("geodesyTransactionManager")
public class RestTest extends AbstractTransactionalTestNGSpringContextTests {

    @Autowired
    private WebApplicationContext webApplicationContext;

    protected static MockMvc mvc;

    @BeforeClass
    public void setUp() throws Exception {
        mvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
    }

    protected String siteLogsDir() {
        return "src/test/resources/sitelog/";
    }

    protected List<File> siteLogs() throws Exception {
        List<File> files = new ArrayList<>();
        Path siteLogsDirPath = FileSystems.getDefault().getPath(siteLogsDir());
        try (DirectoryStream<Path> paths = Files.newDirectoryStream(siteLogsDirPath, "*.xml")) {
            for (Path p : paths) {
                files.add(p.toFile());
            }
        } catch (DirectoryIteratorException e) {
            throw e.getCause();
        }
        return files;
    }
}
