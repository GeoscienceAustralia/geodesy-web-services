package au.gov.ga.geodesy.port.adapter.rest;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.fileUpload;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import static au.gov.ga.geodesy.port.adapter.rest.ResultHandlers.print;

import au.gov.ga.geodesy.support.spring.IntegrationTest;

import org.springframework.test.annotation.Rollback;
import org.springframework.mock.web.MockMultipartFile;
import org.testng.annotations.Test;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.util.Arrays;


public class AssociatedDocumentEndpointITest extends IntegrationTest {

    private String documentName = "ALIC_ant_000_20191027T143000.jpg";
    private String fileReference = "http://localhost:4572/gnss-metadata-document-storage-local/" + this.documentName;
    private String endpoint = "/associatedDocuments/" + this.documentName;

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
        mvc.perform(delete("/associatedDocuments/removeOrphanDocuments")
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isNoContent());
    }
}
