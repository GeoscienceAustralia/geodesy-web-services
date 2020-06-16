package au.gov.ga.geodesy.support.spring;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.NegatedRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.security.web.header.writers.CacheControlHeadersWriter;
import org.springframework.security.web.header.writers.DelegatingRequestMatcherHeaderWriter;
import org.springframework.security.web.header.HeaderWriter;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    /**
     * See javadoc for WebSecurityConfigurerAdapter.
     */
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    /**
     * See javadoc for WebSecurityConfigurerAdapter.
     */
    @Override
    public void configure(AuthenticationManagerBuilder builder) throws Exception {
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        RequestMatcher notResourcesMatcher = new NegatedRequestMatcher(new AntPathRequestMatcher("/associatedDocuments/**"));
        HeaderWriter notResourcesHeaderWriter = new DelegatingRequestMatcherHeaderWriter(notResourcesMatcher , new CacheControlHeadersWriter());
        http.headers().addHeaderWriter(notResourcesHeaderWriter).cacheControl().disable();
    }
}
