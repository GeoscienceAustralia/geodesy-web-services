package au.gov.ga.geodesy.support.mapper.dozer.converter;

import au.gov.ga.geodesy.exception.GeodesyRuntimeException;
import net.opengis.iso19139.gco.v_20070417.CodeListValueType;

/**
 * There are a number of classes that extend CodeListValueType and the converter fired for each of these is CodeListValueTypeConverter.
 * However each type needs an opportunity to do the conversion. This is a base class for the classes that have that purpose.
 * 
 * @author brookes
 *
 */
public abstract class CodeListValueTypeConverterInstanceBase {
    private CodeListValueType codeListValueType;

    protected void setCodeListValueType(CodeListValueType codeListValueType) {
        this.codeListValueType = codeListValueType;
    }

    protected CodeListValueType getCodeListValueType() {
        if (this.codeListValueType == null) {
            throw new GeodesyRuntimeException("ERROR - this.codeListValueType not defined!");
        }
        return this.codeListValueType;
    }

    public CodeListValueType doConversion(String sourceInput) {
        setValue(sourceInput);
        setCodeList(sourceInput);
        setCodeListValue(sourceInput);
        setCodeSpace(sourceInput);
        return getCodeListValueType();
    }

    public abstract void setValue(String value);

    public abstract void setCodeList(String codeList);

    public abstract void setCodeListValue(String codeListValue);

    public abstract void setCodeSpace(String codeSpace);

}
