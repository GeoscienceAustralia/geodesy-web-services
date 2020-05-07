package au.gov.ga.geodesy.port.adapter.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.SdkClientException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import au.gov.ga.geodesy.support.credstash.Credstash;
import au.gov.ga.geodesy.support.credstash.CredstashConfig;

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
        value = "/",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<String> upload(@RequestPart("file") MultipartFile file)
            throws SdkClientException, AmazonServiceException, URISyntaxException, IOException {
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
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.setLocation(new URI(objectUrl));
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

    @ExceptionHandler(value = {AmazonServiceException.class, SdkClientException.class, URISyntaxException.class})
    public ResponseEntity<String> handleExceptions(Exception e) {
        log.error(e.getMessage(), e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }

    @Configuration
    @Import(CredstashConfig.class)
    @PropertySource("classpath:/config.properties")
    public static class AmazonS3ContextConfiguration {
        @Autowired
        private Credstash credstash;

        @Bean
        public AmazonS3 s3Client() {
            BasicAWSCredentials awsCredentials = new BasicAWSCredentials(
                this.credstash.getSecret(this.checkEnvVariableSuffix(this.awsAccessKeyName)),
                this.credstash.getSecret(this.checkEnvVariableSuffix(this.awsSecretKeyName))
            );
            return AmazonS3ClientBuilder
                .standard()
                .withPathStyleAccessEnabled(true)
                .withRegion(Regions.AP_SOUTHEAST_2)
                .withCredentials(new AWSStaticCredentialsProvider(awsCredentials))
                .build();
        }

        @Value("${gnssMetadataAccessKeyId}")
        private String awsAccessKeyName;

        @Value("${gnssMetadataSecretAccessKey}")
        private String awsSecretKeyName;

        @Value("${gnssMetadataDocumentBucketName}")
        private String bucketName;

        @Bean
        public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
            return new PropertySourcesPlaceholderConfigurer();
        }

        @Bean
        public String bucketName() {
            return this.bucketName;
        }

        /**
         * Check the suffix of the variable name by replacing "-dev", "-local" or "-test" with "-nonprod",
         * and keeping the suffix "-prod" unchanged.
         */
        private String checkEnvVariableSuffix(String variableName) {
            String envVariable = variableName.toLowerCase();
            if (envVariable.endsWith("-dev")) {
                envVariable = envVariable.replace("-dev", "-nonprod");
            } else if (envVariable.endsWith("-local")) {
                envVariable = envVariable.replace("-local", "-nonprod");
            } else if (envVariable.endsWith("-test")) {
                envVariable = envVariable.replace("-test", "-nonprod");
            }
            return envVariable;
        }
    }
}
