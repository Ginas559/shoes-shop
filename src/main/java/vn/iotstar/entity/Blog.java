package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "BLOG")
@NamedQuery(name = "Blog.findAll", query = "SELECT b FROM Blog b")
public class Blog implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MABLOG", length = 50)
    private String maBlog;

    @Column(name = "TIEUDE", columnDefinition = "nvarchar(250)")
    private String tieuDe;

    @Column(name = "NOIDUNG", columnDefinition = "nvarchar(max)")
    private String noiDung;

    @Column(name = "NGAYDANG")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayDang;

    public Blog() {}

    public String getMaBlog() { return maBlog; }
    public void setMaBlog(String maBlog) { this.maBlog = maBlog; }
    public String getTieuDe() { return tieuDe; }
    public void setTieuDe(String tieuDe) { this.tieuDe = tieuDe; }
    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }
    public Date getNgayDang() { return ngayDang; }
    public void setNgayDang(Date ngayDang) { this.ngayDang = ngayDang; }
}
