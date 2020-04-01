package au.gov.ga.geodesy.port.adapter.rest;

import static io.restassured.config.XmlConfig.xmlConfig;
import static io.restassured.module.mockmvc.RestAssuredMockMvc.given;

import static org.hamcrest.Matchers.equalTo;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;

import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

import io.restassured.module.mockmvc.RestAssuredMockMvc;

public class SkeletonEndpointITest extends IntegrationTest {

    @Test()
    @Rollback(false)
    public void testFindSkeletonHeaderForCUT0() throws Exception {
        given()
            .when()
            .get("/skeleton/cut0.skl")
            .then()
                .log().body()
                .statusCode(HttpStatus.OK.value())
                .contentType("text/plain");
    }

    @Test()
    @Rollback(false)
    public void testFindSkeletonHeaderForALIC00AUS() throws Exception {
        given()
            .when()
            .get("/skeleton/ALIC00AUS.SKL")
            .then()
            .log().body()
            .statusCode(HttpStatus.OK.value())
            .contentType("text/plain application/json");
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
