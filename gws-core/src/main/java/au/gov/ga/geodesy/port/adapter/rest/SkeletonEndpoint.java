package au.gov.ga.geodesy.port.adapter.rest;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import au.gov.ga.geodesy.domain.model.sitelog.GnssAntennaLogItem;
import au.gov.ga.geodesy.domain.model.sitelog.GnssReceiverLogItem;
import com.vividsolutions.jts.geom.Point;
import org.apache.commons.lang3.tuple.MutableTriple;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.rest.webmvc.PersistentEntityResource;
import org.springframework.data.rest.webmvc.PersistentEntityResourceAssembler;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.hateoas.config.EnableEntityLinks;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;
import au.gov.ga.gnss.support.rinex.RinexFileHeader;

@RepositoryRestController
@EnableEntityLinks
@RequestMapping("/skeleton")
public class SkeletonEndpoint {

    private static final Logger log = LoggerFactory.getLogger(SiteLogEndpoint.class);
    private static final String regex = "^(?<site>[A-Z0-9_]{4})([0-9]{2}[A-Z]{3})?\\.SKL$";
    private static final Pattern pattern = Pattern.compile(regex);

    @Autowired
    private SiteLogRepository siteLogs;

    @Transactional
    @RequestMapping(
        value = "/{filename}",
        method = RequestMethod.GET,
        produces = "text/plain")
    @ResponseBody
    public ResponseEntity<PersistentEntityResource> findByFourCharacterId(
            @PathVariable String filename,
            PersistentEntityResourceAssembler assembler) {

        String fourCharId = extractFourCharacterId(filename);
        if (fourCharId == null) {
            log.error("Invalid skeleton file request received: " + filename);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        try {
            SiteLog siteLog = siteLogs.findByFourCharacterId(fourCharId);
            if (siteLog == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }

            /***
             * SOLO                                                        MARKER NAME
             * 51202M001                                                   MARKER NUMBER
             *                     Geoscience Australia                    OBSERVER / AGENCY
             * 5041K71018          TRIMBLE NETR9       5.44                REC # / TYPE / VERS
             * 954                 JAVRINGANT_DM   NONE                    ANT # / TYPE
             *  -5911340.1240  2156887.2990 -1038664.0050                  APPROX POSITION XYZ
             *         0.0010        0.0000        0.0000                  ANTENNA: DELTA H/E/N
             *                                                             END OF HEADER
             */

            String markerName = fourCharId;
            String markerNumber = siteLog.getSiteIdentification().getIersDOMESNumber();
            String observerAgency = "Geoscience Australia";

            RinexFileHeader rinexFileHeader = new RinexFileHeader();
            rinexFileHeader.setMarkerName(markerName);
            rinexFileHeader.setMarkerNumber(markerNumber);
            // rinexFileHeader.setObserverAgency(observerAgency);

            List<GnssReceiverLogItem> receiverLogItemList =
                    new ArrayList<GnssReceiverLogItem>(siteLog.getGnssReceivers());
            receiverLogItemList.sort(Comparator.comparing(GnssReceiverLogItem::getDateInstalled).reversed());

            GnssReceiverLogItem receiverLogItem = receiverLogItemList.get(0);
            rinexFileHeader.setReceiverSerialNumber(receiverLogItem.getSerialNumber());
            rinexFileHeader.setReceiverType(receiverLogItem.getType());
            rinexFileHeader.setReceiverFirmwareVersion(receiverLogItem.getFirmwareVersion());

            List<GnssAntennaLogItem> antennaLogItemList = new ArrayList<GnssAntennaLogItem>(siteLog.getGnssAntennas());
            antennaLogItemList.sort(Comparator.comparing(GnssAntennaLogItem::getDateInstalled).reversed());

            GnssAntennaLogItem antennaLogItem = antennaLogItemList.get(0);
            rinexFileHeader.setAntennaSerialNumber(antennaLogItem.getSerialNumber());
            rinexFileHeader.setAntennaType(antennaLogItem.getType());

            Point position = siteLog.getSiteLocation().getApproximatePosition().getCartesianPosition();
            rinexFileHeader.setApproxPositionXyz(new MutableTriple<Double, Double, Double>(
                    position.getCoordinate().x, position.getCoordinate().y, position.getCoordinate().z));

            rinexFileHeader.setAntennaMarkerArp(new MutableTriple<Double, Double, Double>(
                    antennaLogItem.getMarkerArpUpEcc(),
                    antennaLogItem.getMarkerArpEastEcc(),
                    antennaLogItem.getMarkerArpNorthEcc()));

            return ResponseEntity.ok(assembler.toResource(rinexFileHeader));
        } catch (Exception e) {
            // In case of invalid site log file, no receiver or no antenna records at all, etc.
            log.error("Invalid siteLogItem for site " + fourCharId);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    /**
     * Extract the four character id from skeleton file request.
     */
    String extractFourCharacterId(String identifier) {
        Matcher matcher = pattern.matcher(identifier);
        if (matcher.find()) {
            return matcher.group("site");
        }
        return null;
    }
}
