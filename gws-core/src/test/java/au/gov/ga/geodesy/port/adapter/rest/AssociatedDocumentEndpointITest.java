package au.gov.ga.geodesy.port.adapter.rest;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.fileUpload;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import static au.gov.ga.geodesy.port.adapter.rest.ResultHandlers.print;

import au.gov.ga.geodesy.support.spring.IntegrationTest;

import org.springframework.test.annotation.Rollback;
import org.springframework.mock.web.MockMultipartFile;
import org.testng.annotations.Test;
import java.io.InputStream;
import java.io.ByteArrayInputStream;


public class AssociatedDocumentEndpointITest extends IntegrationTest {

    private String documentName = "ALIC_ant_000_20191027T143000.jpg";
    private String fileReference = "http://localhost:4572/gnss-metadata-document-storage-local/" + this.documentName;

    @Test
    @Rollback(false)
    public void uploadSiteImageToS3Bucket() throws Exception {
        InputStream fileContent = new ByteArrayInputStream("Dummy testing image content".getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/upload")
            .file(mockFile)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isOk())
            .andExpect(content().string(containsString(this.fileReference)));
    }

    @Test(dependsOnMethods = {"uploadSiteImageToS3Bucket"})
    @Rollback(false)
    public void deleteSiteImageFromS3Bucket() throws Exception {
        mvc.perform(delete("/associatedDocuments/" + this.documentName)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isOk());
    }
}
