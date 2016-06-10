package au.gov.ga.geodesy.support.mapper.orika;

import ma.glasnost.orika.converter.BidirectionalConverter;
import ma.glasnost.orika.metadata.Type;

/**
 * {@BidirectionalAssignableConverter} extends the applicability of Orika's
 * {@BidirectionalConverter} to include destination types that are assignable
 * from the declared destination types A and B. Orika library will use this
 * converter when trying to map to destination types @{code ? super A} and
 * @{code ? super B}.
 */
public abstract class BidirectionalAssignableConverter<A, B> extends BidirectionalConverter<A, B> {

    @Override
    public boolean canConvert(Type<?> sourceType, Type<?> targetType) {
        return (sourceType.equals(super.sourceType) && targetType.isAssignableFrom(super.destinationType))
            || (sourceType.equals(super.destinationType) && targetType.isAssignableFrom(super.sourceType));
    }
}
