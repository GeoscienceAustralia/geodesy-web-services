package au.gov.ga.geodesy.support.spring;

import static com.jayway.restassured.RestAssured.get;
import static com.jayway.restassured.RestAssured.given;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.support.TestResources;

@ContextConfiguration(
    classes = {},
    loader = AnnotationConfigContextLoader.class
)
public class StandaloneIntegrationTest extends AbstractTestNGSpringContextTests {

    /* private static final String webServicesUrl = "http://geodesywebservicedloadbalancer-259979095.ap-southeast-2.elb.amazonaws.com"; */
    private static final String webServicesUrl = "http://localhost:8080/geodesy-web-services";

    /* @Test */
    public void test() {
        get(webServicesUrl + "/corsSites")
            .then().assertThat().statusCode(200)
            .and().log().body();
    }

    private void uploadSopacSiteLog(File siteLog) throws Exception {
        given()
            .contentType("application/xml")
            .body(FileUtils.readFileToString(siteLog))
        .when()
            .post(webServicesUrl + "/siteLog/sopac/upload")
        .then()
            .statusCode(201);
    }

    /* @Test */
    public void uploadAliceSopacSiteLog() throws Exception {
        uploadSopacSiteLog(TestResources.sopacSiteLog("ALIC"));
    }

    /* @Test */
    public void uploadSopacSiteLogs() throws Exception {
        for (File siteLog : TestResources.sopacSiteLogs()) {
            uploadSopacSiteLog(siteLog);
        }
    }
}
