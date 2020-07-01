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
        "                    Geoscience Australia - Longer than 4... OBSERVER / AGENCY\n" +
        "1830439             LEICA GR25          4.11.606/6.523      REC # / TYPE / VERS\n" +
        "09370001            LEIAR25.R3      NONE                    ANT # / TYPE\n" +
        " -4130636.5890  2894953.1210 -3890530.4420                  APPROX POSITION XYZ\n" +
        "        0.0015        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n" +
        "G   16 C1C L1C D1C S1C C2W L2W D2W S2W C2X L2X D2X S2X C5X  SYS / # / OBS TYPES\n" +
        "       L5X D5X S5X                                          SYS / # / OBS TYPES\n" +
        "R   16 C1C L1C D1C S1C C1P L1P D1P S1P C2C L2C D2C S2C C2P  SYS / # / OBS TYPES\n" +
        "       L2P D2P S2P                                          SYS / # / OBS TYPES\n" +
        "E   20 C1C L1C D1C S1C C5Q L5Q D5Q S5Q C7Q L7Q D7Q S7Q C8Q  SYS / # / OBS TYPES\n" +
        "       L8Q D8Q S8Q C6C L6C D6C S6C                          SYS / # / OBS TYPES\n" +
        "C   12 C2I L2I D2I S2I C6I L6I D6I S6I C7I L7I D7I S7I      SYS / # / OBS TYPES\n" +
        "J   16 C1C L1C D1C S1C C2S L2S D2S S2S C2L L2L D2L S2L C5Q  SYS / # / OBS TYPES\n" +
        "       L5Q D5Q S5Q                                          SYS / # / OBS TYPES\n" +
        "                                                            END OF HEADER\n";

    private String mobsSkeleton =
        "MOBS                                                        MARKER NAME\n" +
        "50182M001                                                   MARKER NUMBER\n" +
        "                    Geoscience Australia                    OBSERVER / AGENCY\n" +
        "3007645             SEPT POLARX4TR      2.9.6               REC # / TYPE / VERS\n" +
        "CR20020709          ASH701945C_M    NONE                    ANT # / TYPE\n" +
        " -4130636.5890  2894953.1210 -3890530.4420                  APPROX POSITION XYZ\n" +
        "        0.0000        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n" +
        "G   16 C1C L1C D1C S1C C2W L2W D2W S2W C2X L2X D2X S2X C5X  SYS / # / OBS TYPES\n" +
        "       L5X D5X S5X                                          SYS / # / OBS TYPES\n" +
        "R   16 C1C L1C D1C S1C C1P L1P D1P S1P C2C L2C D2C S2C C2P  SYS / # / OBS TYPES\n" +
        "       L2P D2P S2P                                          SYS / # / OBS TYPES\n" +
        "E   20 C1C L1C D1C S1C C5Q L5Q D5Q S5Q C7Q L7Q D7Q S7Q C8Q  SYS / # / OBS TYPES\n" +
        "       L8Q D8Q S8Q C6C L6C D6C S6C                          SYS / # / OBS TYPES\n" +
        "C   12 C2I L2I D2I S2I C6I L6I D6I S6I C7I L7I D7I S7I      SYS / # / OBS TYPES\n" +
        "J   16 C1C L1C D1C S1C C2S L2S D2S S2S C2L L2L D2L S2L C5Q  SYS / # / OBS TYPES\n" +
        "       L5Q D5Q S5Q                                          SYS / # / OBS TYPES\n" +
        "                                                            END OF HEADER\n";

    private String airaSkeleton =
        "AIRA                                                        MARKER NAME\n" +
        "21742S001                                                   MARKER NUMBER\n" +
        "                    Geospatial Information Authority of ... OBSERVER / AGENCY\n" +
        "5134K78052          TRIMBLE NETR9       4.61                REC # / TYPE / VERS\n" +
        "4938353451          TRM59800.00     SCIS                    ANT # / TYPE\n" +
        " -4130636.5890  2894953.1210 -3890530.4420                  APPROX POSITION XYZ\n" +
        "        0.0000        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n" +
        "G   20 C1C L1C D1C S1C C1W L1W D1W S1W C2W L2W D2W S2W C2L  SYS / # / OBS TYPES\n" +
        "       L2L D2L S2L C5Q L5Q D5Q S5Q                          SYS / # / OBS TYPES\n" +
        "R   16 C1C L1C D1C S1C C1P L1P D1P S1P C2P L2P D2P S2P C2C  SYS / # / OBS TYPES\n" +
        "       L2C D2C S2C                                          SYS / # / OBS TYPES\n" +
        "E   20 C1X L1X D1X S1X C5X L5X D5X S5X C6X L6X D6X S6X C7X  SYS / # / OBS TYPES\n" +
        "       L7X D7X S7X C8X L8X D8X S8X                          SYS / # / OBS TYPES\n" +
        "C   12 C2I L2I D2I S2I C6I L6I D6I S6I C7I L7I D7I S7I      SYS / # / OBS TYPES\n" +
        "J   12 C1C L1C D1C S1C C2X L2X D2X S2X C5X L5X D5X S5X      SYS / # / OBS TYPES\n" +
        "                                                            END OF HEADER\n";

    @Test
    @Rollback(false)
    public void upload() throws Exception {
        SiteLog alic = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("ALIC")).getSiteLog();
        siteLogService.upload(alic);
        SiteLog mobs = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("MOBS")).getSiteLog();
        siteLogService.upload(mobs);
        SiteLog aira = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("AIRA-collocationInfo")).getSiteLog();
        siteLogService.upload(aira);
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

    @Test(dependsOnMethods = {"upload"})
    @Rollback(false)
    public void testSeptentrioObsTypes() throws Exception {
        String text = given()
            .when()
            .get("/skeletonFiles/mobs.skl")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertTrue(text.equals(mobsSkeleton));
    }

    @Test(dependsOnMethods = {"upload"})
    @Rollback(false)
    public void testTrimbleObsTypes() throws Exception {
        String text = given()
            .when()
            .get("/skeletonFiles/aira.skl")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertTrue(text.equals(airaSkeleton));
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
