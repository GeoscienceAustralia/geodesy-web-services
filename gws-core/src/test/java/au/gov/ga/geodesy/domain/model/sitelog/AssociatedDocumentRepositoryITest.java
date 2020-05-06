package au.gov.ga.geodesy.domain.model.sitelog;

import java.util.List;
import java.util.Set;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.isIn;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

public class AssociatedDocumentRepositoryITest extends IntegrationTest {

    @Autowired
    private AssociatedDocumentRepository associatedDocuments;

    @Autowired
    private SiteLogRepository siteLogs;

    @Test
    @Rollback(false)
    public void saveAlic() throws Exception {
        String[] documentNames = {"ALIC_ant_000_20191027T143000.jpg", "ALIC_ant_090_20191027T143500.jpg"};
        SiteLog siteLog = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("ALIC-with-2-associated-documents")).getSiteLog();
        Set<AssociatedDocument> documents = siteLog.getAssociatedDocuments();
        assertThat(documents.size(), is(2));

        AssociatedDocument d1 = documents.iterator().next();
        assertThat(d1.getName(), isIn(documentNames));

        siteLogs.saveAndFlush(siteLog);

        AssociatedDocument d2 = associatedDocuments.findByName(d1.getName());
        assertThat(d2.getName(), isIn(documentNames));
    }

    @Test
    @Rollback(false)
    public void saveMobs() throws Exception {
        SiteLog siteLog = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("MOBS")).getSiteLog();
        Set<AssociatedDocument> documents = siteLog.getAssociatedDocuments();
        assertThat(documents.size(), is(1));

        AssociatedDocument d1 = documents.iterator().next();
        assertThat(d1.getName(), is("MOBS_ant_000_20191027T143000.jpg"));

        associatedDocuments.saveAndFlush(d1);
        AssociatedDocument d2 = associatedDocuments.findByName(d1.getName());
        assertThat(d2.getName(), is(d1.getName()));
    }
}
