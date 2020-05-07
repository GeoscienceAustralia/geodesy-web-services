package au.gov.ga.geodesy.support.credstash;

import com.amazonaws.regions.Regions;
import me.lamouri.JCredStash;

/**
 * JCredStash creates AWS SDK clients for DynamoDB and KMS services, which are
 * relatively expensive operations. This class, together with
 * @{code CredstashConfig}, provides a singleton mechanism to ensure that only
 * one JCredStash instance is created and re-used by all clients.
 *
 * @see me.lamouri.JCredStash;
 */
public class Credstash {

    private JCredStash jCredStash = new JCredStash(Regions.AP_SOUTHEAST_2);

    /**
     * Use the instance provided by {@code CredstashConfig}.
     */
    Credstash() {
    }

    /**
     * Fetch a secret from credstash.
     */
    public String getSecret(String key) {
        return this.jCredStash.getSecret("credential-store", key);
    }
}
