package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "BANNER")
@NamedQuery(name = "Banner.findAll", query = "SELECT b FROM Banner b")
public class Banner implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MABANNER", length = 50)
    private String maBanner;

    @Column(name = "TENBANNER", columnDefinition = "nvarchar(200)")
    private String tenBanner;

    @Column(name = "LINK", length = 500)
    private String link;

    @Column(name = "ANH", columnDefinition = "nvarchar(500)")
    private String anh;

    public Banner() {}

    public String getMaBanner() { return maBanner; }
    public void setMaBanner(String maBanner) { this.maBanner = maBanner; }
    public String getTenBanner() { return tenBanner; }
    public void setTenBanner(String tenBanner) { this.tenBanner = tenBanner; }
    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }
    public String getAnh() { return anh; }
    public void setAnh(String anh) { this.anh = anh; }
}
