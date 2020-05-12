package au.gov.ga.geodesy.port.adapter.rest;

import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.service.CorsSiteLogService;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import static io.restassured.module.mockmvc.RestAssuredMockMvc.given;
import static org.junit.Assert.assertTrue;

public class SkeletonEndpointITest extends IntegrationTest {

    @Autowired
    private CorsSiteLogService siteLogService;

    private String alicSkeleton =
        "ALIC                                                        MARKER NAME\n" +
        "50137M001                                                   MARKER NUMBER\n" +
        "                    Geoscience Australia                    OBSERVER / AGENCY\n" +
        "1830439             LEICA GR25          4.31.101            REC # / TYPE / VERS\n" +
        "09370001            LEIAR25.R3      NONE                    ANT # / TYPE\n" +
        " -4052051.7670  4212836.2150 -2545106.0270                  APPROX POSITION XYZ\n" +
        "        0.0015        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n" +
        "                                                            END OF HEADER\n";

    @Test
    @Rollback(false)
    public void upload() throws Exception {
        SiteLog alic = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("ALIC")).getSiteLog();
        siteLogService.upload(alic);
    }

    @Test(dependsOnMethods = {"upload"})
    @Rollback(false)
    public void testFindSkeletonHeaderForALIC00AUS() throws Exception {
        String text = given()
            .when()
            .get("/skeletonFiles/ALIC00AUS.SKL")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertTrue(text.equals(alicSkeleton));
    }

    @Test(dependsOnMethods = {"upload"})
    @Rollback(false)
    public void testFindSkeletonHeaderForALIC() throws Exception {
        String text = given()
            .when()
            .get("/skeletonFiles/alic.skl")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertTrue(text.equals(alicSkeleton));
    }

    @Test
    public void testNotFound() throws Exception {
        given()
            .when()
            .get("/skeletonFiles/0000.SKL")
            .then()
            .statusCode(HttpStatus.NOT_FOUND.value());
    }

    @Test
    public void testInvalid() throws Exception {
        given()
            .when()
            .get("/skeletonFiles/123456789.xyz")
            .then()
            .statusCode(HttpStatus.NOT_FOUND.value());
    }
}
