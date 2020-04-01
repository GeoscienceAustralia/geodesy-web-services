package au.gov.ga.geodesy.domain.model.sitelog;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QueryDslPredicateExecutor;
import org.springframework.data.repository.query.Param;

public interface AssociatedDocumentRepository extends
        AssociatedDocumentRepositoryCustom,
        JpaRepository<AssociatedDocument, Integer>,
        QueryDslPredicateExecutor<AssociatedDocument> {

    @Override
    List<AssociatedDocument> findAll();

    @Query("select d from AssociatedDocument d where d.id = :id")
    AssociatedDocument findById(@Param("id") Integer id);

    @Query("select d from AssociatedDocument d where d.name = :name")
    AssociatedDocument findByName(@Param("name") String name);
}
