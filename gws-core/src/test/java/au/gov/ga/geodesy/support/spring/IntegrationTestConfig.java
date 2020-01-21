package au.gov.ga.geodesy.support.spring;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.aspectj.EnableSpringConfigured;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;


/**
 * Spring context configuration for integration tests.
 *
 * @see {@code src/test/resources/integration-test.properties}
 */
@Configuration
@Import({
        Config.class,
        GeodesySupportConfig.class,
        GeodesyRepositoryRestMvcConfig.class,
        GeodesyRestMvcConfig.class,
        GeodesyServiceTestConfig.class,
        PersistenceJpaConfig.class,
        SecurityConfig.class,
        ResourceServerTestConfig.class,
    })
@EnableSpringConfigured
@EnableAspectJAutoProxy(proxyTargetClass = true)
@PropertySource("classpath:/integration-test.properties")
public class IntegrationTestConfig {

    @Value("${dbUrl}")
    private String dbUrl;

    @Value("${dbUsername}")
    private String dbUsername;

    @Value("${dbPassword}")
    private String dbPassword;

    @Value("${gnss_metadata_document_bucket_name}")
    private String documentBucketName;

    @Bean
    public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }

    @Bean
    public String gnssMetadataDocumentBucketName() {
        return this.documentBucketName;
    }

    @Bean
    public AmazonS3 s3Client() {
        return AmazonS3ClientBuilder
            .standard()
            .withPathStyleAccessEnabled(true)
            .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration("http://localhost:4572", "ap-southeast-2"))
            .disableChunkedEncoding()
            .build();
    }

    public String getDbUrl() {
        return dbUrl;
    }

    public String getDbUsername() {
        return dbUsername;
    }

    public String getDbPassword() {
        return dbPassword;
    }
}
