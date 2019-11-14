package au.gov.ga.geodesy.domain.model.sitelog;

import java.time.Instant;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.validation.constraints.Past;
import javax.validation.constraints.Size;

import org.apache.commons.lang3.builder.CompareToBuilder;

/**
 * AssociatedDocuments is one of the three elements in Remarks Group which is added to SiteLog in GeodeyML 0.5
 *
 * <group name="RemarksGroup">
 *   <annotation>
 *     <documentation>A convenience group. This allows an application schema developer to include remarks and associated documents in a standard fashion.</documentation>
 *   </annotation>
 *   <sequence>
 *     <element minOccurs="0" name="notes" type="string"/>
 *     <element maxOccurs="unbounded" minOccurs="0" name="associatedDocument" type="geo:DocumentPropertyType"/>
 *     <element minOccurs="0" name="extension" type="anyType"/>
 *   </sequence>
 * </group>
 */
@Entity
@Table(name = "SITELOG_ASSOCIATEDDOCUMENT")
public class AssociatedDocument implements Comparable<AssociatedDocument> {

    @Id
    @GeneratedValue(generator = "surrogateKeyGenerator")
    @SequenceGenerator(name = "surrogateKeyGenerator", sequenceName = "SEQ_SITELOGASSOCIATEDDOCUMENT")
    private Integer id;

    @Size(max = 256)
    @Column(name = "NAME", length = 256, unique = true, nullable = false)
    protected String name;

    @Size(max = 256)
    @Column(name = "FILE_REFERENCE", length = 256, unique = true, nullable = false)
    protected String fileReference;

    @Size(max = 256)
    @Column(name = "DESCRIPTION", length = 256)
    protected String description;

    @Size(max = 100)
    @Column(name = "TYPE", length = 100)
    protected String type;

    @Past
    @Column(name = "CREATED_DATE")
    protected Instant createdDate;

    @SuppressWarnings("unused")
    private Integer getId() {
        return id;
    }

    @SuppressWarnings("unused")
    private void setId(Integer id) {
        this.id = id;
    }

    /**
     * Return document name.
     */
    public String getName() {
        return name;
    }

    /**
     * Set document name.
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Return file reference (URL) to the document.
     */
    public String getFileReference() {
        return fileReference;
    }

    /**
     * Set file reference (URL).
     */
    public void setFileReference(String value) {
        this.fileReference = value;
    }

    /**
     * Return document description.
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set document description.
     */
    public void setDescription(String value) {
        this.description = value;
    }

    /**
     * Return document type.
     */
    public String getType() {
        return type;
    }

    /**
     * Set document type.
     */
    public void setType(String value) {
        this.type = value;
    }

    /**
     * Return the document created date.
     */
    public Instant getCreatedDate() {
        return createdDate;
    }

    /**
     * Set the document created date.
     */
    public void setCreatedDate(Instant date) {
        this.createdDate = date;
    }

    @Override
    public int compareTo(AssociatedDocument document) {
        return new CompareToBuilder()
            .append(this.name, document.getName())
            .append(this.fileReference, document.getFileReference())
            .append(this.description, document.getDescription())
            .append(this.type, document.getType())
            .append(this.createdDate, document.getCreatedDate())
            .toComparison();
    }
}
