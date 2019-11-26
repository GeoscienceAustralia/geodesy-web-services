package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.support.java.util.Iso;
import au.gov.ga.geodesy.support.gml.GMLPropertyType;

import ma.glasnost.orika.MapperFacade;
import ma.glasnost.orika.MapperFactory;
import ma.glasnost.orika.impl.DefaultMapperFactory;

import net.opengis.gml.v_3_2_1.AbstractGMLType;

/**
 * Reversible mapping between a GMLPropertyType type and its target element of Object type.
 */
public class SingleLogItemPropertyTypeMapper<P extends GMLPropertyType, T extends AbstractGMLType, O extends Object> implements Iso<P, O> {

    private Iso<P, O> propertyToObjectItemMapper;
    private MapperFacade mapper;

    public SingleLogItemPropertyTypeMapper(Iso<T, O> singleItemMapper) {
        this.propertyToObjectItemMapper = new GMLPropertyTypeMapper<P, T>().compose(singleItemMapper);

        MapperFactory mapperFactory = new DefaultMapperFactory.Builder().build();
        mapperFactory.classMap(GMLPropertyType.class, Object.class).register();
        mapperFactory.getConverterFactory().registerConverter(new InstantToTimePositionConverter());
        this.mapper = mapperFactory.getMapperFacade();
    }

    public O to(P propertyType) {
        O objItem = propertyToObjectItemMapper.to(propertyType);
        mapper.map(propertyType, objItem);
        return objItem;
    }

    public P from(O objItem) {
        P propertyType = propertyToObjectItemMapper.from(objItem);
        mapper.map(objItem, propertyType);
        return propertyType;
    }
}

