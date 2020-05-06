package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import au.gov.ga.geodesy.domain.model.sitelog.AssociatedDocument;
import au.gov.ga.geodesy.support.java.util.Iso;
import au.gov.xml.icsm.geodesyml.v_0_5.DocumentType;

/**
 * Reversible mapping between GeodesyML DocumentType DTO and AssociatedDocument site log entity.
 */
@Component
public class AssociatedDocumentMapper implements Iso<DocumentType, AssociatedDocument> {

    @Autowired
    private GenericMapper mapper;

    /**
     * {@inheritDoc}
     */
    public AssociatedDocument to(DocumentType documentType) {
        return mapper.map(documentType, AssociatedDocument.class);
    }

    /**
     * {@inheritDoc}
     */
    public DocumentType from(AssociatedDocument associatedDocument) {
        return mapper.map(associatedDocument, DocumentType.class);
    }
}
