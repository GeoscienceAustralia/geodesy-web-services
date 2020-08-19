package au.gov.ga.geodesy.port.adapter.rest;

import au.gov.ga.geodesy.domain.model.sitelog.Document;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

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
import com.amazonaws.services.s3.model.ListObjectsRequest;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3ObjectSummary;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.stream.Collectors;
import javax.servlet.http.HttpServletResponse;

import au.gov.ga.geodesy.domain.model.sitelog.DocumentRepository;


@RepositoryRestController
@RequestMapping("/associatedDocuments")
public class AssociatedDocumentEndpoint {

    private static final Logger log = LoggerFactory.getLogger(AssociatedDocumentEndpoint.class);

    @Autowired
    private DocumentRepository documentRepository;

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

    @PostMapping(
        value = "/",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<String> upload(@RequestPart("file") MultipartFile file,
            @RequestParam(required = false) String documentName)
            throws SdkClientException, AmazonServiceException, URISyntaxException, IOException {
        if (documentName == null) {
            documentName = file.getOriginalFilename();
        }
        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(file.getSize());
        objectMetadata.setContentType(file.getContentType());
        objectMetadata.setCacheControl("public,max-age=86400,immutable");

        PutObjectRequest putObjectRequest = new PutObjectRequest(this.bucketName,
                documentName, file.getInputStream(), objectMetadata)
                .withCannedAcl(CannedAccessControlList.PublicRead);
        s3Client.putObject(putObjectRequest);
        URL objectUrl = s3Client.getUrl(this.bucketName, documentName);
        HttpHeaders responseHeaders = new HttpHeaders();
        if (objectUrl != null) {
            String location = "/associatedDocuments/" + documentName;
            responseHeaders.setLocation(new URI(location));
            log.info("Uploaded " + documentName + " to S3 bucket: " + objectUrl);
        }
        return new ResponseEntity<String>(responseHeaders, HttpStatus.CREATED);
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<String> remove(@PathVariable("name") String documentName)
            throws SdkClientException, AmazonServiceException {
        if (s3Client.doesObjectExist(this.bucketName, documentName)) {
            DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(this.bucketName, documentName);
            s3Client.deleteObject(deleteObjectRequest);
            log.info("Delete " + documentName + " from S3 bucket " + this.bucketName + ": done");
            return new ResponseEntity<String>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/{name}")
    public void redirect(HttpServletResponse response, @PathVariable("name") String documentName)
            throws SdkClientException, AmazonServiceException, IOException {
        URL objectUrl = s3Client.getUrl(this.bucketName, documentName);
        response.sendRedirect(objectUrl.toExternalForm());
    }

    @DeleteMapping("/removeOrphanDocuments")
    public ResponseEntity<String> removeOrphanDocuments(@RequestParam(defaultValue = "12") Long hoursToKeep)
            throws SdkClientException, AmazonServiceException {

        Date startDateTime = null;
        if (hoursToKeep > 0) {
            Instant dateTime = Instant.now().minus(hoursToKeep, ChronoUnit.HOURS);
            startDateTime = Date.from(dateTime);
        }

        List<String> objectKeys = this.getAllObjectKeys(startDateTime);
        List<Document> documents = this.documentRepository.findAll();
        List<String> documentNames = documents.stream().map(d -> d.getName()).collect(Collectors.toList());

        int numberOfOrphanDocuments = 0;
        for (String objectKey : objectKeys) {
            if (!documentNames.contains(objectKey)) {
                DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(this.bucketName, objectKey);
                s3Client.deleteObject(deleteObjectRequest);
                numberOfOrphanDocuments++;
            }
        }

        log.info(numberOfOrphanDocuments + " orphan documents have been removed");
        return ResponseEntity.ok().body("Number of orphan documents removed: " + numberOfOrphanDocuments);
    }

    @ExceptionHandler(value = {AmazonServiceException.class, SdkClientException.class, URISyntaxException.class})
    public ResponseEntity<String> handleExceptions(Exception e) {
        log.error(e.getMessage(), e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }

    private List<String> getAllObjectKeys(Date startDateTime) throws SdkClientException, AmazonServiceException {
        List<String> objectKeys = new ArrayList<String>();
        ListObjectsRequest listObjectsRequest = new ListObjectsRequest().withBucketName(this.bucketName);
        ObjectListing objectListing;
        do {
            objectListing = this.s3Client.listObjects(listObjectsRequest);
            for (S3ObjectSummary objectSummary : objectListing.getObjectSummaries()) {
                if (startDateTime == null || objectSummary.getLastModified().compareTo(startDateTime) <= 0) {
                    objectKeys.add(objectSummary.getKey());
                }
            }
            listObjectsRequest.setMarker(objectListing.getNextMarker());
        } while (objectListing.isTruncated());

        return objectKeys;
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
