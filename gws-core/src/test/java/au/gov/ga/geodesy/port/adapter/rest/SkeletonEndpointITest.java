package au.gov.ga.geodesy.port.adapter.rest;

import au.gov.ga.geodesy.support.spring.IntegrationTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import static io.restassured.module.mockmvc.RestAssuredMockMvc.given;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;

public class SkeletonEndpointITest extends IntegrationTest {

    @Test
    @Rollback(false)
    public void testFindSkeletonHeaderForCUT0() throws Exception {
        String text = given()
            .when()
            .get("/skeleton/cut0.skl")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertThat(text, containsString("ANT #"));
        assertThat(text, containsString("59945M001"));
    }

    @Test
    @Rollback(false)
    public void testFindSkeletonHeaderForALIC00AUS() throws Exception {
        String text = given()
            .when()
            .get("/skeleton/ALIC00AUS.SKL")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain")
            .extract().body().asString();

        assertThat(text, containsString("ANTENNA: DELTA"));
        assertThat(text, containsString("50137M001"));
    }

    @Test
    public void testNotFound() throws Exception {
        given()
            .when()
            .get("/skeleton/0000.SKL")
            .then()
            .statusCode(HttpStatus.NOT_FOUND.value());
    }
}
