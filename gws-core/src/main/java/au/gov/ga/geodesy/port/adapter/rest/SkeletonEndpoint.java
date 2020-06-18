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
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/skeletonFiles")
public class SkeletonEndpoint {

    private static final Logger log = LoggerFactory.getLogger(SkeletonEndpoint.class);

    private static final String trimbleObsTypes =
        "G   16 C1C L1C D1C S1C C2W L2W D2W S2W C2X L2X D2X S2X C5X  SYS / # / OBS TYPES\n" +
        "       L5X D5X S5X                                          SYS / # / OBS TYPES\n" +
        "R   16 C1C L1C D1C S1C C1P L1P D1P S1P C2C L2C D2C S2C C2P  SYS / # / OBS TYPES\n" +
        "       L2P D2P S2P                                          SYS / # / OBS TYPES\n" +
        "E   20 C1C L1C D1C S1C C5Q L5Q D5Q S5Q C7Q L7Q D7Q S7Q C8Q  SYS / # / OBS TYPES\n" +
        "       L8Q D8Q S8Q C6C L6C D6C S6C                          SYS / # / OBS TYPES\n" +
        "C   12 C2I L2I D2I S2I C6I L6I D6I S6I C7I L7I D7I S7I      SYS / # / OBS TYPES\n" +
        "J   16 C1C L1C D1C S1C C2S L2S D2S S2S C2L L2L D2L S2L C5Q  SYS / # / OBS TYPES\n" +
        "       L5Q D5Q S5Q                                          SYS / # / OBS TYPES\n";

    private static final String septLeicaObsTypes =
        "G   20 C1C L1C D1C S1C C1W L1W D1W S1W C2W L2W D2W S2W C2L  SYS / # / OBS TYPES\n" +
        "       L2L D2L S2L C5Q L5Q D5Q S5Q                          SYS / # / OBS TYPES\n" +
        "R   16 C1C L1C D1C S1C C1P L1P D1P S1P C2P L2P D2P S2P C2C  SYS / # / OBS TYPES\n" +
        "       L2C D2C S2C                                          SYS / # / OBS TYPES\n" +
        "E   20 C1X L1X D1X S1X C5X L5X D5X S5X C6X L6X D6X S6X C7X  SYS / # / OBS TYPES\n" +
        "       L7X D7X S7X C8X L8X D8X S8X                          SYS / # / OBS TYPES\n" +
        "C   12 C2I L2I D2I S2I C6I L6I D6I S6I C7I L7I D7I S7I      SYS / # / OBS TYPES\n" +
        "J   12 C1C L1C D1C S1C C2X L2X D2X S2X C5X L5X D5X S5X      SYS / # / OBS TYPES\n";

    @Autowired
    private SiteLogRepository siteLogs;

    @Transactional(readOnly = true)
    @RequestMapping(
        value = "/{filename:[a-zA-Z0-9_]{4}(?:[0-9]{2}[a-zA-Z]{3})?\\.(?:(?:SKL)|(?:skl))}",
        method = RequestMethod.GET,
        produces = "text/plain")
    @ResponseBody
    public ResponseEntity<String> findByFourCharacterId(
        @PathVariable String filename) throws IOException {

        String fourCharId = filename.substring(0, 4).toUpperCase();

        SiteLog siteLog = siteLogs.findByFourCharacterId(fourCharId);
        if (siteLog == null) {
            log.error("Failed to retrive site log for station " + fourCharId);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        RinexFileHeader rinexFileHeader = new RinexFileHeader();
        rinexFileHeader.setMarkerName(fourCharId);

        String markerNumber = siteLog.getSiteIdentification().getIersDOMESNumber();
        rinexFileHeader.setMarkerNumber(markerNumber);

        List<SiteResponsibleParty> custodian = siteLog.getSiteMetadataCustodians();
        if (!custodian.isEmpty()) {
            String agency = custodian.get(0).getParty().getOrganisationName().toString();
            // Truncate Organisation name if longer than 40 chars
            // TODO: Add Header comment containing untruncated Organisation Name
            // TODO: Consider doing this in RinexFileHeader class
            if (agency.length() > 40) {
                agency = agency.substring(0, 36) + "...";
            }
            rinexFileHeader.setAgency(agency);
        }

        List<GnssReceiverLogItem> receiverLogItemList = new ArrayList<>(siteLog.getGnssReceivers());
        if (receiverLogItemList.isEmpty()) {
            log.error("No receiver record for station " + fourCharId);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

        GnssReceiverLogItem receiverLogItem = receiverLogItemList.stream()
            .max(GnssReceiverLogItem::compareTo)
            .get();

        rinexFileHeader.setReceiverSerialNumber(receiverLogItem.getSerialNumber());
        rinexFileHeader.setReceiverType(receiverLogItem.getType());
        rinexFileHeader.setReceiverFirmwareVersion(receiverLogItem.getFirmwareVersion());

        List<GnssAntennaLogItem> antennaLogItemList = new ArrayList<>(siteLog.getGnssAntennas());
        if (antennaLogItemList.isEmpty()) {
            log.error("No antenna record for station " + fourCharId);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

        GnssAntennaLogItem antennaLogItem = antennaLogItemList.stream()
            .max(GnssAntennaLogItem::compareTo)
            .get();

        rinexFileHeader.setAntennaSerialNumber(antennaLogItem.getSerialNumber());
        rinexFileHeader.setAntennaType(antennaLogItem.getType());

        Point position = siteLog.getSiteLocation().getApproximatePosition().getCartesianPosition();
        rinexFileHeader.getApproxPositionXyz().setLeft(position.getCoordinate().x);
        rinexFileHeader.getApproxPositionXyz().setMiddle(position.getCoordinate().y);
        rinexFileHeader.getApproxPositionXyz().setRight(position.getCoordinate().z);

        rinexFileHeader.getAntennaMarkerArp().setLeft(antennaLogItem.getMarkerArpUpEcc());
        rinexFileHeader.getAntennaMarkerArp().setMiddle(antennaLogItem.getMarkerArpEastEcc());
        rinexFileHeader.getAntennaMarkerArp().setRight(antennaLogItem.getMarkerArpNorthEcc());

        StringWriter stringWriter = new StringWriter();
        rinexFileHeader.write(stringWriter);
        String headerString = stringWriter.toString();

        // Assume signal types based on receiver type - unknown receiver types will be ignored
        String receiverType = receiverLogItem.getType().toLowerCase();
        if (receiverType.contains("leic") || receiverType.contains("sept")) {
            headerString = headerString.substring(0, 538) + septLeicaObsTypes + headerString.substring(538);
        } else if (receiverType.contains("trim")) {
            headerString = headerString.substring(0, 538) + trimbleObsTypes + headerString.substring(538);
        }

        return ResponseEntity.ok()
            .contentType(MediaType.TEXT_PLAIN)
            .body(headerString);
    }
}
