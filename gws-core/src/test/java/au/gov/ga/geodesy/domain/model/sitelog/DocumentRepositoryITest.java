package au.gov.ga.geodesy.domain.model.sitelog;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.isIn;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import java.util.Set;

import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

public class DocumentRepositoryITest extends IntegrationTest {

    @Autowired
    private DocumentRepository documentRepository;

    @Autowired
    private SiteLogRepository siteLogRepository;

    @Test
    @Rollback(false)
    public void saveAlic() throws Exception {
        String[] documentNames = {"ALIC_ant_000_20191027T143000.jpg", "ALIC_ant_090_20191027T143500.jpg"};
        SiteLog siteLog = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("ALIC-with-2-associated-documents")).getSiteLog();
        Set<Document> documents = siteLog.getDocuments();
        assertThat(documents.size(), is(2));

        Document d1 = documents.iterator().next();
        assertThat(d1.getName(), isIn(documentNames));

        siteLogRepository.saveAndFlush(siteLog);

        Document d2 = documentRepository.findByName(d1.getName());
        assertThat(d2.getName(), isIn(documentNames));
    }

    @Test
    @Rollback(false)
    public void saveMobs() throws Exception {
        SiteLog siteLog = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("MOBS")).getSiteLog();
        Set<Document> documents = siteLog.getDocuments();
        assertThat(documents.size(), is(1));

        Document d1 = documents.iterator().next();
        assertThat(d1.getName(), is("MOBS_ant_000_20191027T143000.jpg"));

        documentRepository.saveAndFlush(d1);
        Document d2 = documentRepository.findByName(d1.getName());
        assertThat(d2.getName(), is(d1.getName()));
    }
}
