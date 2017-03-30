package au.gov.ga.geodesy.support.mapper.orika.geodesyml;

import au.gov.ga.geodesy.domain.model.sitelog.GnssAntennaLogItem;
import au.gov.ga.geodesy.support.java.util.Iso;
import au.gov.xml.icsm.geodesyml.v_0_4.GnssAntennaType;
import au.gov.xml.icsm.geodesyml.v_0_4.IgsAntennaModelCodeType;
import au.gov.xml.icsm.geodesyml.v_0_4.IgsRadomeModelCodeType;
import au.gov.xml.icsm.geodesyml.v_0_4.IgsReceiverModelCodeType;
import ma.glasnost.orika.MapperFacade;
import ma.glasnost.orika.MapperFactory;
import ma.glasnost.orika.converter.ConverterFactory;
import ma.glasnost.orika.impl.DefaultMapperFactory;
import ma.glasnost.orika.metadata.TypeFactory;
import net.opengis.gml.v_3_2_1.CodeType;

/**
 * Reversible mapping between GeodesyML GnssAntennaType DTO and GnssAntennaLogItem site log entity.
 */
public class GnssAntennaMapper implements Iso<GnssAntennaType, GnssAntennaLogItem> {
    private MapperFactory mapperFactory = new DefaultMapperFactory.Builder().build();

    private MapperFacade mapper;

    public GnssAntennaMapper() {

        mapperFactory.classMap(GnssAntennaLogItem.class, GnssAntennaType.class)
		        .fieldMap("type", "igsModelCode").converter("typeConverter").add()
		        .field("serialNumber", "manufacturerSerialNumber")
                .fieldMap("antennaRadomeType", "antennaRadomeType").converter("codeWithAuthorityTypeConverter").add()
                .fieldMap("antennaReferencePoint", "antennaReferencePoint").converter("antennaReferencePointConverter").add()
                .byDefault()
                .register();


        ConverterFactory converters = mapperFactory.getConverterFactory();     
        converters.registerConverter("typeConverter", new StringToCodeListValueConverter<IgsAntennaModelCodeType>(
                "https://igscb.jpl.nasa.gov/igscb/station/general/rcvr_ant.tab",
                "http://xml.gov.au/icsm/geodesyml/codelists/antenna-receiver-codelists.xml#GeodesyML_GNSSAntennaTypeCode"
        ));
        converters.registerConverter("antennaReferencePointConverter", new StringToCodeTypeConverter("eGeodesy/antennaReferencePoint") {});
        converters.registerConverter("codeWithAuthorityTypeConverter", new StringToCodeWithAuthorityTypeConverter<IgsRadomeModelCodeType>("eGeodesy/antennaRadomeType"));
        converters.registerConverter(new InstantToTimePositionConverter());
        mapper = mapperFactory.getMapperFacade();
    }

    @Override
    public GnssAntennaLogItem to(GnssAntennaType antenna) {
        return mapper.map(antenna, GnssAntennaLogItem.class);
    }

    @Override
    public GnssAntennaType from(GnssAntennaLogItem antennaLogItem) {
        return mapper.map(antennaLogItem, GnssAntennaType.class);
    }
}
