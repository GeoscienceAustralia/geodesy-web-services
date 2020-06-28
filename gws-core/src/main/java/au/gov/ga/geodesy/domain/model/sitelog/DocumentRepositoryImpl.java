package au.gov.ga.geodesy.domain.model.sitelog;

import org.springframework.beans.factory.annotation.Autowired;

public class DocumentRepositoryImpl implements DocumentRepositoryCustom {

    @Autowired
    private DocumentRepository documents;

    public void delete(Integer id) {
        Document toDelete = documents.findById(id);
        if (toDelete != null) {
            documents.delete(toDelete);
        }
    }

    public void delete(String name) {
        Document toDelete = documents.findByName(name);
        if (toDelete != null) {
            documents.delete(toDelete);
        }
    }
}
