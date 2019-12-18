package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.domain.model.sitelog.AssociatedDocument;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLMarshaller;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLUtils;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.marshalling.moxy.GeodesyMLMoxy;
import au.gov.ga.geodesy.support.spring.UnitTest;
import au.gov.ga.geodesy.support.utils.GMLDateUtils;
import au.gov.xml.icsm.geodesyml.v_0_5.GeodesyMLType;
import au.gov.xml.icsm.geodesyml.v_0_5.DocumentType;
import au.gov.xml.icsm.geodesyml.v_0_5.SiteLogType;

import org.springframework.beans.factory.annotation.Autowired;
import org.testng.annotations.Test;

import java.io.Reader;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

public class AssociatedDocumentMapperTest extends UnitTest {

    @Autowired
    private AssociatedDocumentMapper mapper;

    private GeodesyMLMarshaller marshaller = new GeodesyMLMoxy();

    /**
     * Test mapping from DocumentType to AssociatedDocument and back
     * to DocumentType.
     */
    @Test
    public void testMapping() throws Exception {
        try (Reader mobs = TestResources.customGeodesyMLSiteLogReader("MOBS")) {
            GeodesyMLType geodesyML = marshaller.unmarshal(mobs, GeodesyMLType.class).getValue();
            SiteLogType siteLogType = GeodesyMLUtils.getElementFromJAXBElements(geodesyML.getElements(), SiteLogType.class)
                .findFirst()
                .get();

            DocumentType documentTypeA = siteLogType.getAssociatedDocument().get(0).getDocument();
            AssociatedDocument document = mapper.to(documentTypeA);

            assertThat(document.getName(), equalTo(documentTypeA.getName().get(0).getValue()));
            assertThat(document.getFileReference(), equalTo(documentTypeA.getBody().getFileReference().getHref()));
            assertThat(document.getDescription(), equalTo(documentTypeA.getDescription().getValue()));
            assertThat(document.getType(), equalTo(documentTypeA.getType().getValue()));
            assertThat(document.getCreatedDate(), equalTo(GMLDateUtils.stringToDateMultiParsers(documentTypeA.getCreatedDate().getValue().get(0))));

            DocumentType documentTypeB = mapper.from(document);

            assertThat(documentTypeB.getName().get(0).getValue(), equalTo(document.getName()));
            assertThat(documentTypeB.getBody().getFileReference().getHref(), equalTo(document.getFileReference()));
            assertThat(documentTypeB.getDescription().getValue(), equalTo(document.getDescription()));
            assertThat(documentTypeB.getType().getValue(), equalTo(document.getType()));
            assertThat(GMLDateUtils.stringToDateMultiParsers(documentTypeB.getCreatedDate().getValue().get(0)), equalTo(document.getCreatedDate()));
        }
    }
}
