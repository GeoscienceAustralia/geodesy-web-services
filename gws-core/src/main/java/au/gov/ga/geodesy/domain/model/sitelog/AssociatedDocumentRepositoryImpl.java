package au.gov.ga.geodesy.domain.model.sitelog;

import org.springframework.beans.factory.annotation.Autowired;

public class AssociatedDocumentRepositoryImpl implements AssociatedDocumentRepositoryCustom {

    @Autowired
    private AssociatedDocumentRepository associatedDocuments;

    public void delete(Integer id) {
        AssociatedDocument toDelete = associatedDocuments.findById(id);
        if (toDelete != null) {
            associatedDocuments.delete(toDelete);
        }
    }

    public void delete(String name) {
        AssociatedDocument toDelete = associatedDocuments.findByName(name);
        if (toDelete != null) {
            associatedDocuments.delete(toDelete);
        }
    }
}
