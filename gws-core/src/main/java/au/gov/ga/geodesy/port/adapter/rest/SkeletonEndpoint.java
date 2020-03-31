package au.gov.ga.geodesy.port.adapter.rest;

import au.gov.ga.geodesy.domain.model.SiteResponsibleParty;
import au.gov.ga.geodesy.domain.model.sitelog.GnssAntennaLogItem;
import au.gov.ga.geodesy.domain.model.sitelog.GnssReceiverLogItem;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLog;
import au.gov.ga.geodesy.domain.model.sitelog.SiteLogRepository;
import au.gov.ga.gnss.support.rinex.RinexFileHeader;
import com.vividsolutions.jts.geom.Point;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.config.EnableEntityLinks;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RestController
@EnableEntityLinks
@RequestMapping("/skeleton")
public class SkeletonEndpoint {

    private static final Logger log = LoggerFactory.getLogger(SiteLogEndpoint.class);

    private static final String regex = "^(?<site>[A-Z0-9_]{4})([0-9]{2}[A-Z]{3})?\\.SKL$";

    private static final Pattern pattern = Pattern.compile(regex);

    @Autowired
    private SiteLogRepository siteLogs;

    @Transactional(readOnly = true)
    @RequestMapping(
        value = "/{filename}",
        method = RequestMethod.GET,
        produces = "text/plain")
    @ResponseBody
    public ResponseEntity<StreamingResponseBody> findByFourCharacterId(
            @PathVariable String filename) {

        String fourCharId = extractFourCharacterId(filename);
        if (fourCharId == null) {
            log.error("Invalid skeleton file request received: " + filename);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        SiteLog siteLog = siteLogs.findByFourCharacterId(fourCharId);
        if (siteLog == null) {
            log.error("Failed to retrive site log for station " + fourCharId);
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

        String agency = "N/A";
        String observer = "N/A";
        List<SiteResponsibleParty> siteContacts = siteLog.getSiteContacts();
        if (!siteContacts.isEmpty()) {
            agency = siteContacts.get(0).getParty().getOrganisationName().toString();
            observer = siteContacts.get(0).getParty().getIndividualName();
        }

        RinexFileHeader rinexFileHeader = new RinexFileHeader();
        rinexFileHeader.setMarkerName(markerName);
        rinexFileHeader.setMarkerNumber(markerNumber);
        rinexFileHeader.setObserver(observer);
        rinexFileHeader.setAgency(agency);

        List<GnssReceiverLogItem> receiverLogItemList = new ArrayList<>(siteLog.getGnssReceivers());
        if (receiverLogItemList.isEmpty()) {
            log.error("No receiver record for station " + fourCharId);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        receiverLogItemList.sort(Comparator.comparing(GnssReceiverLogItem::getDateInstalled).reversed());

        GnssReceiverLogItem receiverLogItem = receiverLogItemList.get(0);
        rinexFileHeader.setReceiverSerialNumber(receiverLogItem.getSerialNumber());
        rinexFileHeader.setReceiverType(receiverLogItem.getType());
        rinexFileHeader.setReceiverFirmwareVersion(receiverLogItem.getFirmwareVersion());

        List<GnssAntennaLogItem> antennaLogItemList = new ArrayList<>(siteLog.getGnssAntennas());
        if (antennaLogItemList.isEmpty()) {
            log.error("No antenna record for station " + fourCharId);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        antennaLogItemList.sort(Comparator.comparing(GnssAntennaLogItem::getDateInstalled).reversed());

        GnssAntennaLogItem antennaLogItem = antennaLogItemList.get(0);
        rinexFileHeader.setAntennaSerialNumber(antennaLogItem.getSerialNumber());
        rinexFileHeader.setAntennaType(antennaLogItem.getType());

        Point position = siteLog.getSiteLocation().getApproximatePosition().getCartesianPosition();
        rinexFileHeader.getApproxPositionXyz().setLeft(position.getCoordinate().x);
        rinexFileHeader.getApproxPositionXyz().setMiddle(position.getCoordinate().y);
        rinexFileHeader.getApproxPositionXyz().setRight(position.getCoordinate().z);

        rinexFileHeader.getAntennaMarkerArp().setLeft(antennaLogItem.getMarkerArpUpEcc());
        rinexFileHeader.getAntennaMarkerArp().setMiddle(antennaLogItem.getMarkerArpEastEcc());
        rinexFileHeader.getAntennaMarkerArp().setRight(antennaLogItem.getMarkerArpNorthEcc());

        return ResponseEntity.ok(outputStream -> rinexFileHeader.write(new OutputStreamWriter(outputStream)));
    }

    /**
     * Extract the four character id from skeleton file request.
     */
    private String extractFourCharacterId(String identifier) {
        Matcher matcher = pattern.matcher(identifier);
        if (matcher.find()) {
            return matcher.group("site");
        }
        return null;
    }
}
