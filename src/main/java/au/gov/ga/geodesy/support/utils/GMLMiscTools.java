package au.gov.ga.geodesy.support.utils;

import java.util.ArrayList;
import java.util.List;

import au.gov.xml.icsm.geodesyml.v_0_3.CountryCodeType;

public class GMLMiscTools {
    public static String getEmptyString() {
        return "";
    }

    public static Double getEmptyDouble() {
        return 0.0;
    }

    public static <T> List<T> getEmptyList(Class<T> clazz) {
        List<T> list = new ArrayList<>();
        return list;
    }

    public static <T> List<T> getEmptyList(Class<T> clazz, T dummyItem) {
        List<T> list = getEmptyList(clazz);
        list.add(dummyItem);
        return list;
    }

    public static Object getEmptyCountryCode() {
        CountryCodeType countryCodeType = new CountryCodeType();
        countryCodeType.setCodeListValue("");
        return countryCodeType;
    }
}
