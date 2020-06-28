package au.gov.ga.geodesy.domain.model.sitelog;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QueryDslPredicateExecutor;
import org.springframework.data.repository.query.Param;

public interface DocumentRepository extends
        DocumentRepositoryCustom,
        JpaRepository<Document, Integer>,
        QueryDslPredicateExecutor<Document> {

    @Override
    List<Document> findAll();

    @Query("select d from Document d where d.id = :id")
    Document findById(@Param("id") Integer id);

    @Query("select d from Document d where d.name = :name")
    Document findByName(@Param("name") String name);
}
