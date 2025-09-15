package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "BINHLUAN")
@NamedQuery(name = "BinhLuan.findAll", query = "SELECT b FROM BinhLuan b")
public class BinhLuan implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MABL", length = 50)
    private String maBl;

    @Column(name = "NOIDUNG", columnDefinition = "nvarchar(max)")
    private String noiDung;

    @Column(name = "NGAYBL")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayBl;

    @Column(name = "MAKH", length = 50)
    private String maKh;

    @Column(name = "MASP", length = 50)
    private String maSp;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAKH", insertable=false, updatable=false)
    private KhachHang khachHang;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MASP", insertable=false, updatable=false)
    private SanPham sanPham;

    public BinhLuan() {}

    public String getMaBl() { return maBl; }
    public void setMaBl(String maBl) { this.maBl = maBl; }
    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }
    public Date getNgayBl() { return ngayBl; }
    public void setNgayBl(Date ngayBl) { this.ngayBl = ngayBl; }
    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public KhachHang getKhachHang() { return khachHang; }
    public void setKhachHang(KhachHang khachHang) { this.khachHang = khachHang; }
    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }
}
