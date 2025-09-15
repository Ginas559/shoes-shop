package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "SODIACHI")
@NamedQuery(name = "SoDiaChi.findAll", query = "SELECT s FROM SoDiaChi s")
public class SoDiaChi implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MASODIACHI", length = 50)
    private String maSoDiaChi;

    @Column(name = "DIACHI", columnDefinition = "nvarchar(500)")
    private String diaChi;

    @Column(name = "MAKH", length = 50)
    private String maKh;

    @Column(name = "MATINH", length = 50)
    private String maTinh;

    @Column(name = "MAQUAN", length = 50)
    private String maQuan;

    @Column(name = "MAPHUONG", length = 50)
    private String maPhuong;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAKH", insertable=false, updatable=false)
    private KhachHang khachHang;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MATINH", insertable=false, updatable=false)
    private Tinh tinh;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAQUAN", insertable=false, updatable=false)
    private Quan quan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAPHUONG", insertable=false, updatable=false)
    private Phuong phuong;

    public SoDiaChi() {}

    public String getMaSoDiaChi() { return maSoDiaChi; }
    public void setMaSoDiaChi(String maSoDiaChi) { this.maSoDiaChi = maSoDiaChi; }
    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }
    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }
    public String getMaTinh() { return maTinh; }
    public void setMaTinh(String maTinh) { this.maTinh = maTinh; }
    public String getMaQuan() { return maQuan; }
    public void setMaQuan(String maQuan) { this.maQuan = maQuan; }
    public String getMaPhuong() { return maPhuong; }
    public void setMaPhuong(String maPhuong) { this.maPhuong = maPhuong; }

    public KhachHang getKhachHang() { return khachHang; }
    public void setKhachHang(KhachHang khachHang) { this.khachHang = khachHang; }
    public Tinh getTinh() { return tinh; }
    public void setTinh(Tinh tinh) { this.tinh = tinh; }
    public Quan getQuan() { return quan; }
    public void setQuan(Quan quan) { this.quan = quan; }
    public Phuong getPhuong() { return phuong; }
    public void setPhuong(Phuong phuong) { this.phuong = phuong; }
}
