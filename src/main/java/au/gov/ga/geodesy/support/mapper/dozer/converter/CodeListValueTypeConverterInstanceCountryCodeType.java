package au.gov.ga.geodesy.support.mapper.dozer.converter;

import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

@Lazy
@Component
public class CodeListValueTypeConverterInstanceCountryCodeType extends CodeListValueTypeConverterInstanceBase {

    @Override
    public void setValue(String value) {
        getCodeListValueType().setValue(value);
    }

    @Override
    public void setCodeList(String codeList) {
        getCodeListValueType().setCodeList(
                "http://xml.gov.au/icsm/geodesyml/codelists/countryCodes_codelist.xml#GeodesyML_CountryCode");
    }

    @Override
    public void setCodeListValue(String codeListValue) {
        getCodeListValueType().setCodeListValue(codeListValue);
    }

    @Override
    public void setCodeSpace(String codeSpace) {
        getCodeListValueType().setCodeSpace("urn:iso:country-code");
    }
}
