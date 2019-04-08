package au.gov.ga.geodesy.domain.model.event;

import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.ForeignKey;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;
import java.time.Instant;

import org.checkerframework.checker.nullness.qual.MonotonicNonNull;

@Entity
@Table(name = "CORS_SITE_REMOVED_FROM_NETWORK")
@DiscriminatorValue("cors site removed from network")
@PrimaryKeyJoinColumn(foreignKey=@ForeignKey(name = "fk_domain_event_cors_site_removed_from_network"))
public class CorsSiteRemovedFromNetwork extends Event {

    @Column(name = "SITE_ID", nullable = false)
    private @MonotonicNonNull Integer siteId;

    @Column(name = "NETWORK_ID", nullable = false)
    private @MonotonicNonNull Integer networkId;

    @Column(name = "EFFECTIVE_FROM")
    private @MonotonicNonNull Instant effectiveFrom;

    @SuppressWarnings({"unused", "initialization.fields.uninitialized"}) // used by hibernate
    private CorsSiteRemovedFromNetwork() {
    }

    public CorsSiteRemovedFromNetwork(Integer siteId, Integer networkId, Instant effectiveFrom) {
        this.siteId = siteId;
        this.networkId = networkId;
        this.effectiveFrom = effectiveFrom;
    }

    public Integer getSiteId() {
        return siteId;
    }

    public Integer getNetworkId() {
        return networkId;
    }

    public Instant getEffectiveFrom() {
        return effectiveFrom;
    }
}
