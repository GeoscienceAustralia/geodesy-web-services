package au.gov.ga.geodesy.port.adapter.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentialsProviderChain;
import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;
import com.amazonaws.auth.InstanceProfileCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.SdkClientException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;

import javax.servlet.http.HttpServletRequest;
import java.io.InputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.concurrent.TimeUnit;

@RepositoryRestController
@RequestMapping("/associatedDocuments")
public class AssociatedDocumentEndpoint {

    private static final Logger log = LoggerFactory.getLogger(AssociatedDocumentEndpoint.class);

    @Autowired
    private AmazonS3 s3Client;

    @Autowired
    private String bucketName;

    public AssociatedDocumentEndpoint() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(AmazonS3ContextConfiguration.class);
        context.refresh();
        this.s3Client = (AmazonS3) context.getBean("s3Client");
        this.bucketName = (String) context.getBean("bucketName");
    }

    @GetMapping("/{name}")
    public ResponseEntity<StreamingResponseBody> getDocumentContent(
            @PathVariable("name") String documentName)
            throws SdkClientException {
        GetObjectRequest getObjectRequest = new GetObjectRequest(this.bucketName, documentName);
        S3Object documentObject = this.s3Client.getObject(getObjectRequest);
        ObjectMetadata objectMetadata = documentObject.getObjectMetadata();

        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.ACCEPT_RANGES, "bytes");
        headers.set(HttpHeaders.CONTENT_DISPOSITION, "inline; preview-type=application/html");
        headers.set(HttpHeaders.CONTENT_TYPE, objectMetadata.getContentType());
        headers.set(HttpHeaders.ETAG, objectMetadata.getETag());
        headers.setCacheControl("max-age=86401");
        headers.setContentLength(objectMetadata.getContentLength());

        StreamingResponseBody responseBody = outputStream -> {
            try (InputStream inputStream = documentObject.getObjectContent()) {
                int numberOfBytes;
                byte[] data = new byte[1024];
                while ((numberOfBytes = inputStream.read(data, 0, data.length)) != -1) {
                    outputStream.write(data, 0, numberOfBytes);
                }
            }
        };
        CacheControl cacheControl = CacheControl.maxAge(24, TimeUnit.HOURS)
                                                .noTransform()
                                                .cachePublic();
        return ResponseEntity.ok().headers(headers)
                             .cacheControl(cacheControl)
                             .body(responseBody);
    }

    @PostMapping(
        value = "/",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<String> upload(HttpServletRequest httpServletRequest,
                                         @RequestPart("file") MultipartFile file)
            throws SdkClientException, URISyntaxException, IOException {
        String documentName = file.getOriginalFilename();
        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(file.getSize());
        objectMetadata.setContentType(file.getContentType());
        objectMetadata.setCacheControl("public,max-age=86400,immutable");

        PutObjectRequest putObjectRequest = new PutObjectRequest(this.bucketName,
                documentName, file.getInputStream(), objectMetadata)
                .withCannedAcl(CannedAccessControlList.PublicRead);
        s3Client.putObject(putObjectRequest);
        String objectUrl = s3Client.getUrl(this.bucketName, documentName).toExternalForm();
        HttpHeaders responseHeaders = new HttpHeaders();
        if (objectUrl.contains(documentName)) {
            String location = this.getDocumentLocation(httpServletRequest, documentName);
            responseHeaders.setLocation(new URI(location));
            log.info("Uploaded " + documentName + " to S3 bucket: " + location);
        }
        return new ResponseEntity<String>(responseHeaders, HttpStatus.CREATED);
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<String> remove(@PathVariable("name") String documentName)
            throws SdkClientException {
        if (s3Client.doesObjectExist(this.bucketName, documentName)) {
            DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(this.bucketName, documentName);
            s3Client.deleteObject(deleteObjectRequest);
            log.info("Delete " + documentName + " from S3 bucket " + this.bucketName + ": done");
            return new ResponseEntity<String>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
    }

    @ExceptionHandler(value = {AmazonServiceException.class, SdkClientException.class, URISyntaxException.class})
    public ResponseEntity<String> handleExceptions(Exception e) {
        log.error(e.getMessage(), e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }

    private String getDocumentLocation(HttpServletRequest request, String documentName) {
        String documentLocation = request.getRequestURL() + documentName;
        if (request.getScheme().equals("http") && !request.getServerName().contains("localhost")) {
            documentLocation = documentLocation.replace("http", "https");
        }
        return documentLocation;
    }

    @Configuration
    @PropertySource("classpath:/config.properties")
    public static class AmazonS3ContextConfiguration {
        @Bean
        public AmazonS3 s3Client() {
            return AmazonS3ClientBuilder
                .standard()
                .withPathStyleAccessEnabled(true)
                .withRegion(Regions.AP_SOUTHEAST_2)
                .withCredentials(
                    new AWSCredentialsProviderChain(
                        new InstanceProfileCredentialsProvider(false),
                        new EnvironmentVariableCredentialsProvider()
                    )
                )
                .build();
        }

        @Value("${gnssMetadataDocumentBucketName}")
        private String bucketName;

        @Bean
        public String bucketName() {
            return this.bucketName;
        }

        @Bean
        public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
            return new PropertySourcesPlaceholderConfigurer();
        }
    }
}
