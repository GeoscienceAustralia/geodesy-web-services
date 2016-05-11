package au.gov.ga.geodesy.support.mapper.dozer.converter;

import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

@Lazy
@Component
public class CodeListValueTypeConverterInstanceDefault extends CodeListValueTypeConverterInstanceBase {

    @Override
    public void setValue(String value) {
        getCodeListValueType().setValue(value);
    }

    @Override
    public void setCodeList(String codeList) {
        getCodeListValueType().setCodeList(codeList);
    }

    @Override
    public void setCodeListValue(String codeListValue) {
        getCodeListValueType().setCodeListValue(codeListValue);
    }

    @Override
    public void setCodeSpace(String codeSpace) {
        getCodeListValueType().setCodeSpace(codeSpace);
    }
}
