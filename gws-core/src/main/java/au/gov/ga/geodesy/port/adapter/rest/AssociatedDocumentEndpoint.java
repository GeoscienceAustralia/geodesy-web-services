package au.gov.ga.geodesy.port.adapter.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.auth.AWSCredentialsProviderChain;
import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;
import com.amazonaws.auth.InstanceProfileCredentialsProvider;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;


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

    @PostMapping(
        value = "/upload",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<String> upload(
            @RequestPart("file") MultipartFile file) {
        try {
            String documentName = file.getOriginalFilename();
            ObjectMetadata objectMetadata = new ObjectMetadata();
            objectMetadata.setContentLength(file.getSize());
            objectMetadata.setContentType(file.getContentType());

            PutObjectRequest putObjectRequest = new PutObjectRequest(this.bucketName,
                    documentName, file.getInputStream(), objectMetadata)
                    .withCannedAcl(CannedAccessControlList.PublicRead);
            s3Client.putObject(putObjectRequest);
            String objectUrl = s3Client.getUrl(this.bucketName, documentName).toExternalForm();
            log.info("Uploaded " + documentName + " to S3 bucket: " + objectUrl);
            return new ResponseEntity<String>(objectUrl, HttpStatus.OK);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<String> remove(@PathVariable("name") String documentName) {
        try {
            if (doesBucketContainObject(this.bucketName, documentName)) {
                DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(this.bucketName, documentName);
                s3Client.deleteObject(deleteObjectRequest);
                log.info("Delete " + documentName + " from S3 bucket " + this.bucketName + ": done");
            }
            return new ResponseEntity<String>(HttpStatus.OK);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
    }

    private boolean doesBucketContainObject(String bucketName, String objectName) {
        try {
            return s3Client.doesObjectExist(bucketName, objectName);
        } catch (Exception e) {
            return false;
        }
    }

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
                        new ProfileCredentialsProvider("gnss-metadata"),
                        new EnvironmentVariableCredentialsProvider()
                    )
                )
                .build();
        }

        @Value("${gnss_metadata_document_bucket_name}")
        private String bucketName;

        @Bean
        public String bucketName() {
            return this.bucketName;
        }
    }
}
