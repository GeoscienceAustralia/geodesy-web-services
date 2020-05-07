package au.gov.ga.geodesy.support.credstash;

import org.springframework.context.annotation.Bean;

/**
 * Provide a singleton instance of {@code Credstash}.
 */
public class CredstashConfig {

    @Bean
    public Credstash credstash() {
        return new Credstash();
    }
}
