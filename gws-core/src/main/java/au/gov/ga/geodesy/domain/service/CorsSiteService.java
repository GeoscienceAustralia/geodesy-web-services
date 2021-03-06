package au.gov.ga.geodesy.domain.service;

import java.util.Optional;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StopWatch;

import au.gov.ga.geodesy.domain.model.CorsSite;
import au.gov.ga.geodesy.domain.model.CorsSiteRepository;
import au.gov.ga.geodesy.domain.model.Monument;
import au.gov.ga.geodesy.domain.model.event.Event;
import au.gov.ga.geodesy.domain.model.event.EventPublisher;
import au.gov.ga.geodesy.domain.model.event.EventSubscriber;
import au.gov.ga.geodesy.domain.model.event.SiteLogReceived;
import au.gov.ga.geodesy.domain.model.event.SiteUpdated;
import au.gov.ga.geodesy.domain.model.sitelog.SiteIdentification;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;

@Component
@Transactional("geodesyTransactionManager")
public class CorsSiteService implements EventSubscriber<SiteLogReceived> {

    private static final Logger log = LoggerFactory.getLogger(CorsSiteService.class);

    @Autowired
    private SiteLogRepository siteLogs;

    @Autowired
    private CorsSiteRepository corsSites;

    @Autowired
    private EventPublisher eventPublisher;

    @Autowired
    private SetupService setupService;

    @PostConstruct
    private void subscribe() {
        eventPublisher.subscribe(this);
    }

    public boolean canHandle(Event e) {
        return e instanceof SiteLogReceived;
    }

    public void handle(SiteLogReceived siteLogReceived) {
        log.info("Notified of " + siteLogReceived);

        String fourCharacterId = siteLogReceived.getFourCharacterId();
        CorsSite site = this.updateSite(fourCharacterId);
        corsSites.saveAndFlush(site);
        setupService.createSetups(site);

        eventPublisher.handled(siteLogReceived);
        eventPublisher.publish(new SiteUpdated(fourCharacterId));
    }

    public CorsSite updateSite(String fourCharacterId) {
        SiteLog siteLog = siteLogs.findByFourCharacterId(fourCharacterId);

        CorsSite corsSite = Optional.ofNullable(corsSites.findByFourCharacterId(fourCharacterId))
            .orElse(new CorsSite(fourCharacterId));

        corsSite.setName(siteLog.getSiteIdentification().getSiteName());

        if (siteLog.getSiteLocation().getApproximatePosition() != null) {
            corsSite.setApproximatePosition(
                siteLog.getSiteLocation().getApproximatePosition().getGeodeticPosition()
            );
        }

        SiteIdentification siteId = siteLog.getSiteIdentification();
        corsSite.setDomesNumber(siteId.getIersDOMESNumber());
        corsSite.setDateInstalled(siteId.getDateInstalled());

        Monument monument = new Monument();
        monument.setDescription(siteId.getMonumentDescription());
        monument.setHeight(siteId.getHeightOfMonument());
        monument.setFoundation(siteId.getMonumentFoundation());
        monument.setMarkerDescription(siteId.getMarkerDescription());
        corsSite.setMonument(monument);

        log.info("Saving site: " + fourCharacterId);
        return corsSite;
    }

    /**
     * Update CorsSites
     */
    @Async
    public void updateSites() {
        StopWatch w = new StopWatch();
        w.start();
        this.corsSites.findAll().forEach(site -> {
            CorsSiteService.this.updateSite(site.getFourCharacterId());
        });
        w.stop();
        log.info("Updated all CorsSites in " + w.getTotalTimeSeconds() + " seconds.");
    }
}
