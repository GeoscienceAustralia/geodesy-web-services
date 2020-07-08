package au.gov.ga.geodesy.domain.model.sitelog;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.startsWith;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.isIn;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import java.util.List;
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
    public void saveDocumentsForAlic() throws Exception {
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
}
