package au.gov.ga.geodesy.domain.model.sitelog;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QueryDslPredicateExecutor;
import org.springframework.data.repository.query.Param;

public interface DocumentRepository extends
        JpaRepository<Document, Integer>,
        QueryDslPredicateExecutor<Document> {

    @Override
    List<Document> findAll();

    Document findByName(@Param("name") String name);

    @Query("select d.name from Document d where d.name like concat(UPPER(:fourCharacterId),'%')")
    List<String> findDocumentNamesByFourCharacterId(@Param("fourCharacterId") String fourCharacterId);
}
