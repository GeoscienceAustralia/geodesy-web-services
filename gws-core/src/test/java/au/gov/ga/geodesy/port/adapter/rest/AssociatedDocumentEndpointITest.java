package au.gov.ga.geodesy.port.adapter.rest;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.fileUpload;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import static au.gov.ga.geodesy.port.adapter.rest.ResultHandlers.print;

import au.gov.ga.geodesy.support.spring.IntegrationTest;

import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import java.io.InputStream;
import java.io.ByteArrayInputStream;

public class AssociatedDocumentEndpointITest extends IntegrationTest {

    private String documentName = "ALIC_ant_000_20191027T143000.jpg";
    private String endpoint = "/associatedDocuments/" + this.documentName;
    private String documentContent = "Dummy testing image content";

    @Test
    @Rollback(false)
    public void uploadDocument() throws Exception {
        InputStream fileContent = new ByteArrayInputStream(this.documentContent.getBytes());
        MockMultipartFile mockFile = new MockMultipartFile("file", this.documentName, "image/jpg", fileContent);
        mvc.perform(fileUpload("/associatedDocuments/")
            .file(mockFile)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isCreated())
            .andExpect(header().string("location", containsString(this.endpoint)));
    }

    @Test(dependsOnMethods = {"uploadDocument"})
    @Rollback(false)
    public void getDocumentContent() throws Exception {
        mvc.perform(get("/associatedDocuments/" + this.documentName))
            .andDo(print)
            .andExpect(status().isOk());
    }

    @Test(dependsOnMethods = {"getDocumentContent"})
    @Rollback(false)
    public void deleteDocument() throws Exception {
        mvc.perform(delete("/associatedDocuments/" + this.documentName)
            .with(super.superuserToken()))
            .andDo(print)
            .andExpect(status().isNoContent());
    }
}
