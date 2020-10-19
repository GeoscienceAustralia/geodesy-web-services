package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import au.gov.ga.geodesy.domain.model.sitelog.Document;
import au.gov.ga.geodesy.support.java.util.Iso;
import au.gov.xml.icsm.geodesyml.v_0_5.DocumentType;

/**
 * Reversible mapping between GeodesyML DocumentType DTO and Document site log entity.
 */
@Component
public class DocumentMapper implements Iso<DocumentType, Document> {

    @Autowired
    private GenericMapper mapper;

    /**
     * {@inheritDoc}
     */
    public Document to(DocumentType documentType) {
        return mapper.map(documentType, Document.class);
    }

    /**
     * {@inheritDoc}
     */
    public DocumentType from(Document document) {
        return mapper.map(document, DocumentType.class);
    }
}
