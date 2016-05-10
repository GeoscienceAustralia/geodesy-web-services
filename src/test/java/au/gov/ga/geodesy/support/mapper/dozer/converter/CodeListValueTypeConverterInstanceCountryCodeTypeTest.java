package au.gov.ga.geodesy.support.mapper.dozer.converter;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import net.opengis.iso19139.gco.v_20070417.CodeListValueType;

public class CodeListValueTypeConverterInstanceCountryCodeTypeTest {

    private CodeListValueTypeConverterInstanceCountryCodeType ctv = new CodeListValueTypeConverterInstanceCountryCodeType();
    private CodeListValueType codeListValueType = new CodeListValueType();

    @Before
    public void init() {
        ctv.setCodeListValueType(codeListValueType);
    }

    @Test
    public void test01() {
        String source = "AUS";

        CodeListValueType codeListValueType = ctv.doConversion(source);
        Assert.assertEquals("http://xml.gov.au/icsm/geodesyml/codelists/countryCodes_codelist.xml#GeodesyML_CountryCode", codeListValueType.getCodeList());
        Assert.assertEquals("AUS", codeListValueType.getCodeListValue());
        Assert.assertEquals("urn:iso:country-code", codeListValueType.getCodeSpace());
        System.out.println(codeListValueType);
    }

}
