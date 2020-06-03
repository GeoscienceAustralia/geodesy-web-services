package au.gov.ga.geodesy.domain.model.sitelog;

import afu.org.apache.commons.lang3.builder.EqualsBuilder;
import afu.org.apache.commons.lang3.builder.HashCodeBuilder;
import afu.org.apache.commons.lang3.builder.ToStringBuilder;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import com.google.common.collect.ComparisonChain;
import com.google.common.collect.Ordering;

import java.time.Instant;

/**
 * http://sopac.ucsd.edu/ns/geodesy/doc/igsSiteLog/equipment/2004/baseEquipmentLib.xsd:baseSensorEquipmentType.effectiveDates Note: this is an attempt to
 * interpret date values as java dates, rather than as strings as defined in the SOPAC schema (feel free to revert to java strings, if this starts to cause
 * trouble).
 */
@Embeddable
public class EffectiveDates implements Comparable<EffectiveDates> {

    @Column(name = "EFFECTIVE_FROM")
    private Instant from;

    @Column(name = "EFFECTIVE_TO")
    private Instant to;

    public EffectiveDates() {
    }

    public EffectiveDates(Instant from) {
        this(from, null);
    }

    public EffectiveDates(Instant from, Instant to) {
        this.from = from;
        this.to = to;
    }

    public Instant getFrom() {
        return from;
    }

    public Instant getTo() { return to; }

    @Override
    public int hashCode() {
        return new HashCodeBuilder().append(this.from).append(this.to).toHashCode();
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof EffectiveDates)) {
            return false;
        }
        if (this == object) {
            return true;
        }
        EffectiveDates other = (EffectiveDates) object;

        return new EqualsBuilder().append(this.from, other.from).append(this.to, other.to).isEquals();
    }

    @Override
    public int compareTo(EffectiveDates x) {
        return ComparisonChain.start()
            .compare(this.from, x.from, Ordering.natural().nullsFirst())
            .compare(this.to, x.to, Ordering.natural().nullsFirst())
            .result();
    }

    public boolean inRange(Instant time) {
        if (time == null) {
            return false;
        }
        return (this.getFrom() == null || this.getFrom().compareTo(time) <= 0)
            && (this.getTo() == null || this.getTo().compareTo(time) >= 0);
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("From", this.from).append("To", this.to).toString();
    }
}
