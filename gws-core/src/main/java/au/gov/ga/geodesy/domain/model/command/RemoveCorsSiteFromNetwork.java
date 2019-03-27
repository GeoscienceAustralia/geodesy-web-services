package au.gov.ga.geodesy.domain.model.command;

import java.time.Instant;

public class RemoveCorsSiteFromNetwork {

    private Integer networkId;
    private Instant effectiveFrom;

    public RemoveCorsSiteFromNetwork(Integer networkId, Instant effectiveFrom) {
        this.networkId = networkId;
        this.effectiveFrom = effectiveFrom;
    }

    public Integer getNetworkId() {
        return networkId;
    }

    public Instant  getEffectiveFrom() {
        return effectiveFrom;
    }
}
