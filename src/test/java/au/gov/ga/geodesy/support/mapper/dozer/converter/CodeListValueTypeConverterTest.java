package au.gov.ga.geodesy.support.mapper.dozer.converter;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import au.gov.xml.icsm.geodesyml.v_0_4.IgsReceiverModelCodeType;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Matchers;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.runners.MockitoJUnitRunner;

import au.gov.ga.geodesy.exception.GeodesyRuntimeException;
import net.opengis.iso19139.gco.v_20070417.CodeListValueType;

/**
 * CodeListValueTypeConverter is handling the CodeListValueType super-type and these extensions (directly or indirectly via inheritance).
 * au.gov.xml.icsm.geodesyml.v_0_3.IgsReceiverModelCodeType
 * au.gov.xml.icsm.geodesyml.v_0_3.IgsAntennaModelCodeType
 *
 */
@RunWith(MockitoJUnitRunner.class)
public class CodeListValueTypeConverterTest {
    @Mock
    private CodeListValueTypeConverterInstanceFactory codeListValueTypeConverterInstanceFactory = new CodeListValueTypeConverterInstanceFactory();

    private CodeListValueTypeConverterInstanceDefault defaultConverter = new CodeListValueTypeConverterInstanceDefault();

    @InjectMocks
    private CodeListValueTypeConverter ctv;

    @Before
    public void init() {
        Mockito.when(codeListValueTypeConverterInstanceFactory.getCodeListValueTypeConverterInstance(Matchers.any()))
                .thenReturn(defaultConverter);
    }

    @Test
    public void testStringSourceDestinationCodeListValueTypeNull() {
        CodeListValueType destination = null;
        String source = "banana";
        CodeListValueType emptyCodeListValueType = new CodeListValueType();

        // .setCodeListValueType() only necessary due to the Mockito.when init
        defaultConverter.setCodeListValueType(emptyCodeListValueType);

        CodeListValueType c = (CodeListValueType) ctv.convert(destination, source, CodeListValueType.class,
                String.class);

        Assert.assertEquals(source, c.getValue());
    }

    @Test
    public void testStringSourceDestinationCodeListValueTypeNotNull() {
        CodeListValueType destination = new CodeListValueType();
        destination.setValue("Not a banana");
        String source = "banana";

        // .setCodeListValueType() only necessary due to the Mockito.when init
        defaultConverter.setCodeListValueType(destination);

        CodeListValueType c = (CodeListValueType) ctv.convert(destination, source, CodeListValueType.class,
                String.class);

        Assert.assertEquals(source, c.getValue());
    }

    @Test
    public void testCodeListValueTypeSourceDestinationStringNull() {
        String destination = null;
        CodeListValueType source = new CodeListValueType();
        source.setValue("banana");
        String c = (String) ctv.convert(destination, source, String.class, CodeListValueType.class);

        Assert.assertEquals(source.getValue(), c);
    }

    @Test
    public void testCodeListValueTypeSourceDestinationStringNotNull() {
        String destination = "not a banana";
        CodeListValueType source = new CodeListValueType();
        source.setValue("banana");
        String c = (String) ctv.convert(destination, source, String.class, CodeListValueType.class);

        Assert.assertEquals(source.getValue(), c);
    }

    // ========================

    // Since .setCodeListValueType() not called due to Mockito.when init
    @Test(expected = GeodesyRuntimeException.class)
    public void testNoArgShouldThrowException() {
        IgsReceiverModelCodeType destination = null;
        String source = "banana";
        @SuppressWarnings("unused")
        IgsReceiverModelCodeType c = (IgsReceiverModelCodeType) ctv.convert(destination, source,
                IgsReceiverModelCodeType.class, String.class);
    }

    @Test
    public void testStringSourceDestinationIgsReceiverModelCodeListValueTypeNull() {
        IgsReceiverModelCodeType destination = null;
        String source = "banana";

        IgsReceiverModelCodeType emptyCodeListValueType = new IgsReceiverModelCodeType();

        // .setCodeListValueType() only necessary due to the Mockito.when init
        defaultConverter.setCodeListValueType(emptyCodeListValueType);
        IgsReceiverModelCodeType c = (IgsReceiverModelCodeType) ctv.convert(destination, source,
                IgsReceiverModelCodeType.class, String.class);

        Assert.assertEquals(source, c.getValue());
    }

    @Test
    public void testStringSourceDestinationIgsReceiverModelCodeListValueTypeNotNull() {
        IgsReceiverModelCodeType destination = new IgsReceiverModelCodeType();
        String source = "banana";

        // .setCodeListValueType() only necessary due to the Mockito.when init
        defaultConverter.setCodeListValueType(destination);

        IgsReceiverModelCodeType c = (IgsReceiverModelCodeType) ctv.convert(destination, source,
                IgsReceiverModelCodeType.class, String.class);

        Assert.assertEquals(source, c.getValue());
    }

    @Test
    public void testIgsReceiverModelCodeListValueTypeSourceDestinationStringNull() {
        String destination = null;
        IgsReceiverModelCodeType source = new IgsReceiverModelCodeType();
        source.setValue("banana");
        String c = (String) ctv.convert(destination, source, String.class, IgsReceiverModelCodeType.class);

        Assert.assertEquals(source.getValue(), c);
    }

    @Test
    public void testIgsReceiverModelCodeListValueTypeSourceDestinationStringNotNull() {
        String destination = "not a banana";
        IgsReceiverModelCodeType source = new IgsReceiverModelCodeType();
        source.setValue("banana");
        String c = (String) ctv.convert(destination, source, String.class, IgsReceiverModelCodeType.class);

        Assert.assertEquals(source.getValue(), c);
    }

}
