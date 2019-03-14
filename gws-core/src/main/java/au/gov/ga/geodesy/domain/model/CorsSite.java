package au.gov.ga.geodesy.domain.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Stream;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ForeignKey;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.checkerframework.checker.nullness.qual.MonotonicNonNull;
import org.checkerframework.checker.nullness.qual.Nullable;

import au.gov.ga.geodesy.domain.model.command.AddCorsSiteToNetwork;
import au.gov.ga.geodesy.domain.model.command.RemoveCorsSiteFromNetwork;
import au.gov.ga.geodesy.domain.model.event.CorsSiteAddedToNetwork;
import au.gov.ga.geodesy.domain.model.event.CorsSiteRemovedFromNetwork;
import au.gov.ga.geodesy.domain.model.event.Event;

@Entity
@Table(name = "CORS_SITE")
public class CorsSite extends Site {

    /**
     * Business id
     */
    @Column(name = "FOUR_CHARACTER_ID", length = 4, nullable = false, unique = true)
    private String fourCharacterId;

    @Column(name = "DOMES_NUMBER")
    private @MonotonicNonNull String domesNumber;

    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "MONUMENT_ID", foreignKey = @ForeignKey(name="FK_CORS_SITE_MONUMENT"))
    private @MonotonicNonNull Monument monument;

    @Column(name = "GEOLOGIC_CHARACTERISTIC")
    private @MonotonicNonNull String geologicCharacteristic;

    @Column(name = "BEDROCK_TYPE")
    private @MonotonicNonNull String bedrockType;

    @Column(name = "BEDROCK_CONDITION")
    private @MonotonicNonNull String bedrockCondition;

    @Column(name = "SITE_STATUS")
    private String siteStatus = "PUBLIC";

    @OneToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "CORS_SITE_ID")
    private List<NetworkTenancy> networkTenancies = new ArrayList<>();

    @SuppressWarnings({"unused", "initialization.fields.uninitialized"}) // hibernate needs the default constructor
    private CorsSite() {
    }

    public CorsSite(String fourCharacterId) {
        this.fourCharacterId = fourCharacterId;
    }

    public String getFourCharacterId() {
        return fourCharacterId;
    }

    public @Nullable String getDomesNumber() {
        return domesNumber;
    }

    public void setDomesNumber(String domesNumber) {
        this.domesNumber = domesNumber;
    }

    public @Nullable Monument getMonument() {
        return monument;
    }

    public void setMonument(Monument monument) {
        this.monument = monument;
    }

    public @Nullable String getGeologicCharacteristic() {
        return geologicCharacteristic;
    }

    public void setGeologicCharacteristic(String geologicCharacteristic) {
        this.geologicCharacteristic = geologicCharacteristic;
    }

    public @Nullable String getBedrockType() {
        return bedrockType;
    }

    public void setBedrockType(String bedrockType) {
        this.bedrockType = bedrockType;
    }

    public String getSiteStatus() {
        return siteStatus;
    }

    public void setSiteStatus(String siteStatus) {
        this.siteStatus = siteStatus;
    }

    public List<NetworkTenancy> getNetworkTenancies() {
        return Collections.unmodifiableList(networkTenancies);
    }

    public Stream<Event> handle(AddCorsSiteToNetwork command) {
        NetworkTenancy tenancy = new NetworkTenancy(command.getNetworkId(), command.getPeriod());
        if (!this.networkTenancies.contains(tenancy)) {
            this.networkTenancies.add(new NetworkTenancy(command.getNetworkId(), command.getPeriod()));
            return Stream.of(new CorsSiteAddedToNetwork(this.getId(), command.getNetworkId(), command.getPeriod()));
        } else {
            return Stream.empty();
        }
    }

    public Stream<Event> handle(RemoveCorsSiteFromNetwork command) {
        int index = this.findNetworkTenancyIndexByNetworkId(command.getNetworkId());
        if (index != -1) {
            this.networkTenancies.remove(index);
            return Stream.of(new CorsSiteRemovedFromNetwork(this.getId(), command.getNetworkId(), command.getEffectiveFrom()));
        } else {
            return Stream.empty();
        }
    }

    private int findNetworkTenancyIndexByNetworkId(Integer networkId) {
        for (int i = 0; i < this.networkTenancies.size(); i ++) {
            NetworkTenancy networkTenancy = networkTenancies.get(i);
            if (networkTenancy.getCorsNetworkId().equals(networkId)) {
                return i;
            }
        }
        return -1;
    }
}
