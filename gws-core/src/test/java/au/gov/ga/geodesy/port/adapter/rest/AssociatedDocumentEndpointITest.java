package au.gov.ga.geodesy.port.adapter.rest;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.fileUpload;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import static au.gov.ga.geodesy.port.adapter.rest.ResultHandlers.print;

import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;
import au.gov.ga.geodesy.domain.service.CorsSiteLogService;
import au.gov.ga.geodesy.port.adapter.geodesyml.GeodesyMLSiteLogReader;
import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.mock.web.MockMultipartFile;
import org.testng.annotations.Test;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.util.Arrays;


public class AssociatedDocumentEndpointITest extends IntegrationTest {

    @Autowired
    private SiteLogRepository siteLogRepository;

    @Autowired
    private CorsSiteLogService siteLogService;

    private String fourCharacterId = "ALIC";
    private String createdDate = "20191027T143000";
    private String documentName = this.fourCharacterId + "_ant_090_" + this.createdDate + ".jpg";
    private String fileReference = "http://localhost:4572/gnss-metadata-document-storage-local/" + this.documentName;
    private String endpoint = "/associatedDocuments/" + this.documentName;

    @Test
    @Rollback(false)
    public void uploadSiteLog() throws Exception {
        SiteLog siteLog = new GeodesyMLSiteLogReader(
            TestResources.customGeodesyMLSiteLogReader(this.fourCharacterId)
        ).getSiteLog();
        siteLogService.upload(siteLog);
        SiteLog siteLogSaved = siteLogRepository.findByFourCharacterId(this.fourCharacterId);
        assertThat(siteLogSaved.getId(), not(nullValue()));
        assertThat(siteLogSaved.getSiteIdentification().getFourCharacterId(), equalTo(this.fourCharacterId));
    }

    @Test(dependsOnMethods = {"uploadSiteLog"})
    @Rollback(false)
    public void saveDocument() throws Exception {
        String documentType = "ant_090";
        InputStream fileContent = new ByteArrayInputStream("Upload and save document".getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/save")
            .file(mockFile)
            .param("fourCharacterId", this.fourCharacterId)
            .param("documentType", documentType)
            .param("createdDate", this.createdDate)
            .param("webServiceHost", "")
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isCreated());
    }

    @Test(dependsOnMethods = {"saveDocument"})
    @Rollback(false)
    public void saveDuplicateDocument() throws Exception {
        String documentType = "ant_090";
        InputStream fileContent = new ByteArrayInputStream("Duplicate document".getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/save")
            .file(mockFile)
            .param("fourCharacterId", this.fourCharacterId)
            .param("documentType", documentType)
            .param("createdDate", this.createdDate)
            .param("webServiceHost", "")
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isConflict());
    }

    @Test
    @Rollback(false)
    public void uploadDocument() throws Exception {
        InputStream fileContent = new ByteArrayInputStream("Dummy testing image content".getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/")
            .file(mockFile)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isCreated())
            .andExpect(header().string("location", this.endpoint));
    }

    @Test(dependsOnMethods = {"uploadDocument"})
    @Rollback(false)
    public void redirectToDocumentUrl() throws Exception {
        mvc.perform(get("/associatedDocuments/" + this.documentName))
            .andDo(print)
            .andExpect(status().isFound())
            .andExpect(header().string("location", this.fileReference));
    }

    @Test(dependsOnMethods = {"redirectToDocumentUrl"})
    @Rollback(false)
    public void deleteDocument() throws Exception {
        mvc.perform(delete("/associatedDocuments/" + this.documentName)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isNoContent());
    }

    @Test(dependsOnMethods = {"deleteDocument"})
    @Rollback(false)
    public void uploadMultipleDocuments() throws Exception {
        for (String siteId : Arrays.asList("ALIC", "ADE1", "ADE2")) {
            InputStream fileContent = new ByteArrayInputStream((siteId + " image content").getBytes());
            MockMultipartFile mockFile = new MockMultipartFile("file",
                siteId + "_ant_000_20200611T143000.jpg", "image/jpg", fileContent);
            mvc.perform(fileUpload("/associatedDocuments/")
                .file(mockFile)
                .with(super.superuserToken()))
                .andExpect(status().isCreated());
        }
    }

    @Test(dependsOnMethods = {"uploadMultipleDocuments"})
    @Rollback(false)
    public void removeOrphanDocuments() throws Exception {
        mvc.perform(delete("/associatedDocuments/removeOrphanDocuments?hoursToKeep=0")
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isOk());
    }
}
