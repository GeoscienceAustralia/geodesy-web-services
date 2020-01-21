package au.gov.ga.geodesy.port.adapter.rest;

import static io.restassured.module.mockmvc.RestAssuredMockMvc.given;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.fileUpload;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import static au.gov.ga.geodesy.port.adapter.rest.ResultHandlers.print;

import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.service.CorsSiteLogService;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.spring.IntegrationTest;
import au.gov.ga.geodesy.support.TestResources;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.test.annotation.Rollback;
import org.springframework.mock.web.MockMultipartFile;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import java.io.InputStream;
import java.io.ByteArrayInputStream;


public class AssociatedDocumentEndpointITest extends IntegrationTest {

    private String documentName = "ALIC_ant_000_20191027T143000.jpg";
    private String description = "Antenna North Facing";
    private String fileReference = "http://localhost:4572/gnss-metadata-document-storage-local/" + this.documentName;

    @Autowired
    private CorsSiteLogService siteLogService;

    @BeforeClass
    public void setup() throws Exception {
        SiteLog alice = new GeodesyMLSiteLogReader(TestResources.customGeodesyMLSiteLogReader("ALIC-with-2-associated-documents")).getSiteLog();
        siteLogService.upload(alice);
    }

    @Test
    @Rollback(false)
    public void uploadSiteImage() throws Exception {
        InputStream fileContent = new ByteArrayInputStream("Dummy testing image content".getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/upload")
            .file(mockFile)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isOk())
            .andExpect(content().string(containsString(this.fileReference)));
    }

    @Test(dependsOnMethods = {"uploadSiteImage"})
    @Rollback(false)
    public void checkUploadedImage() throws Exception {
        given()
            .when()
            .get("/associatedDocuments/search/findByName?name=" + this.documentName)
            .then()
            .statusCode(HttpStatus.OK.value())
            .log().body()
            .body("description", equalTo(this.description))
            .body("fileReference", equalTo(this.fileReference));
    }

    @Test(dependsOnMethods = {"checkUploadedImage"})
    @Rollback(false)
    public void deleteUploadedImage() throws Exception {
        given()
            .auth().with(super.superuserToken())
            .when()
            .delete("/associatedDocuments/" + this.documentName)
            .then()
            .statusCode(HttpStatus.OK.value());
    }

    @Test(dependsOnMethods = {"deleteUploadedImage"})
    @Rollback(false)
    public void checkAfterDeletion() throws Exception {
        given()
            .when()
            .get("/associatedDocuments/search/findByName?name=" + this.documentName)
            .then()
            .statusCode(HttpStatus.NOT_FOUND.value());
    }
}