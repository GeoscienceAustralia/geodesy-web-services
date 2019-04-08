package au.gov.ga.geodesy.domain.model;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QueryDslPredicateExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RestResource;

import au.gov.ga.geodesy.support.spring.AggregateRepository;

public interface SetupRepository extends AggregateRepository<Setup>, SetupRepositoryCustom, QueryDslPredicateExecutor<Setup> {

    // TODO: test
    @Query(
        "select s from Setup s where s.siteId = :siteId and s.type = :type and s.invalidated = false"
        + " order by s.effectivePeriod.from asc nulls first, s.effectivePeriod.to asc nulls last"
    )
    Page<Setup> findBySiteId(@Param("siteId") Integer id, @Param("type") SetupType type, Pageable pageRequest);

    @RestResource(exported = false)
    @Query(
        "select s from Setup s where s.siteId = :siteId and s.type = :type and s.invalidated = false"
        + " order by s.effectivePeriod.from asc nulls first, s.effectivePeriod.to asc nulls last"
    )
    List<Setup> findBySiteId(@Param("siteId") Integer id, @Param("type") SetupType type);

    @RestResource(exported = false)
    @Query(
        "select s from Setup s where s.siteId = :siteId and s.type = :type and s.invalidated = true"
        + " order by s.effectivePeriod.from asc nulls first, s.effectivePeriod.to asc nulls last"
    )
    List<Setup> findInvalidatedBySiteId(@Param("siteId") Integer id, @Param("type") SetupType type) ;
}
