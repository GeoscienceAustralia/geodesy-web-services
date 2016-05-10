package au.gov.ga.geodesy.support.mapper.dozer.converter;

import net.opengis.iso19139.gco.v_20070417.CodeListValueType;

/**
 * Factory to create CodeListValueTypeConverterInstance's to manage specific needs for converting to CodeListValueType from String.
 * Only one instance of this class will be created by Dozer.
 * 
 * @author brookes
 *
 */
public class CodeListValueTypeConverterInstanceFactory {
    private ConverterInstanceFactory converterInstanceFactory = new ConverterInstanceFactory();
    private CodeListValueTypeConverterInstanceCountryCodeType countryCodeTypeConverter;
    private CodeListValueTypeConverterInstanceDefault defaultConverter;

    public CodeListValueTypeConverterInstanceBase getCodeListValueTypeConverterInstance(
            CodeListValueType codeListValueTypeSuperClass) {
        return converterInstanceFactory.getCodeListValueTypeConverterInstance(codeListValueTypeSuperClass);
    }

    class ConverterInstanceFactory {

        /**
         * 
         * @param codeListValueTypeSuperClass
         * @return a CodeListValueTypeConverterInstanceBase super class that can handle the conversion of String to CodeListValueType based
         *         on the CodeListValueType runtime instance (super-class of it)
         */
        public CodeListValueTypeConverterInstanceBase getCodeListValueTypeConverterInstance(
                CodeListValueType codeListValueTypeSuperClass) {
            CodeListValueTypeConverterInstanceBase converter = null;
            switch (codeListValueTypeSuperClass.getClass().getSimpleName()) {
            case "CountryCodeType":
                converter = getCountryCodeTypeConverter();
                converter.setCodeListValueType(codeListValueTypeSuperClass);
                return converter;
            default:
                converter = getDefaultConverter();
                converter.setCodeListValueType(codeListValueTypeSuperClass);
                return converter;
            }
        }

    }

    CodeListValueTypeConverterInstanceBase getDefaultConverter() {
        if (defaultConverter == null) {
            defaultConverter = new CodeListValueTypeConverterInstanceDefault();
        }
        return defaultConverter;
    }

    CodeListValueTypeConverterInstanceBase getCountryCodeTypeConverter() {
        if (countryCodeTypeConverter == null) {
            countryCodeTypeConverter = new CodeListValueTypeConverterInstanceCountryCodeType();
        }
        return countryCodeTypeConverter;
    }
}
