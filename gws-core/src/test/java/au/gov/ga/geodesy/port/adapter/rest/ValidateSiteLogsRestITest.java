package au.gov.ga.geodesy.port.adapter.rest;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Reader;

import org.apache.commons.io.IOUtils;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.Rollback;
import org.testng.annotations.Test;

import au.gov.ga.geodesy.support.TestResources;
import au.gov.ga.geodesy.support.spring.IntegrationTest;

public class ValidateSiteLogsRestITest extends IntegrationTest {

    private String readFile(Reader reader) throws FileNotFoundException, IOException {
        return IOUtils.toString(reader);
    }

    @Test
    @Rollback(false)
    public void validateMOBS() throws Exception {
        String siteLogText = readFile(TestResources.customGeodesyMLSiteLogReader("MOBS"));
        mvc.perform(post("/siteLogs/validate").contentType(MediaType.APPLICATION_XML).content(siteLogText))
            .andExpect(status().isOk());
    }

    @Test
    @Rollback(false)
    public void invalidateMOBS() throws Exception {
        String siteLogText = readFile(TestResources.customGeodesyMLSiteLogReader("MOBS-invalid-schema"));
        mvc.perform(post("/siteLogs/validate").contentType(MediaType.APPLICATION_XML).content(siteLogText))
            .andExpect(status().isBadRequest())
            .andDo(ResultHandlers.print);
    }

    @Test
    @Rollback(false)
    public void testBadContentType() throws Exception {
        String siteLogText = readFile(TestResources.customGeodesyMLSiteLogReader("MOBS"));
        mvc.perform(post("/siteLogs/validate").contentType(MediaType.APPLICATION_JSON).content(siteLogText))
            .andExpect(status().isUnsupportedMediaType());
    }
}
