package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "SANPHAM")
@NamedQuery(name = "SanPham.findAll", query = "SELECT s FROM SanPham s")
public class SanPham implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MASP", length = 50)  
    private String maSp;

    @Column(name = "TENSANPHAM", columnDefinition = "nvarchar(200) not null")
    private String tenSanPham;

    @Column(name = "MADONGSANPHAM", length = 50)
    private String maDongSanPham;

    @Column(name = "MAMAU", length = 50)
    private String maMau;

    @Column(name = "ANHDAIDIEN", columnDefinition = "nvarchar(500)")
    private String anhDaiDien;

    @Column(name = "ANH1", columnDefinition = "nvarchar(500)")
    private String anh1;

    @Column(name = "ANH2", columnDefinition = "nvarchar(500)")
    private String anh2;

    @Column(name = "ANH3", columnDefinition = "nvarchar(500)")
    private String anh3;

    @Column(name = "GIABAN")
    private Double giaBan;

    @Column(name = "MOTA", columnDefinition = "nvarchar(max)")
    private String moTa;

    // quan he: sanpham -> dong san pham (ManyToOne)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MADONGSANPHAM", insertable=false, updatable=false)
    private DongSanPham dongSanPham;

    // 1 san pham co nhieu chi tiet phieu mua
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL)
    private List<ChiTietPhieuMua> chiTietPhieuMuas = new ArrayList<>();

    // 1 san pham co nhieu binh luan
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL)
    private List<BinhLuan> binhLuans = new ArrayList<>();

    // quan he voi SanPhamSize
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL)
    private List<SanPhamSize> sanPhamSizes = new ArrayList<>();

    public SanPham() {}

    // getters / setters
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }
    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }
    public String getMaDongSanPham() { return maDongSanPham; }
    public void setMaDongSanPham(String maDongSanPham) { this.maDongSanPham = maDongSanPham; }
    public String getMaMau() { return maMau; }
    public void setMaMau(String maMau) { this.maMau = maMau; }
    public String getAnhDaiDien() { return anhDaiDien; }
    public void setAnhDaiDien(String anhDaiDien) { this.anhDaiDien = anhDaiDien; }
    public String getAnh1() { return anh1; }
    public void setAnh1(String anh1) { this.anh1 = anh1; }
    public String getAnh2() { return anh2; }
    public void setAnh2(String anh2) { this.anh2 = anh2; }
    public String getAnh3() { return anh3; }
    public void setAnh3(String anh3) { this.anh3 = anh3; }
    public Double getGiaBan() { return giaBan; }
    public void setGiaBan(Double giaBan) { this.giaBan = giaBan; }
    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public DongSanPham getDongSanPham() { return dongSanPham; }
    public void setDongSanPham(DongSanPham dongSanPham) { this.dongSanPham = dongSanPham; }

    public List<ChiTietPhieuMua> getChiTietPhieuMuas() { return chiTietPhieuMuas; }
    public void setChiTietPhieuMuas(List<ChiTietPhieuMua> chiTietPhieuMuas) { this.chiTietPhieuMuas = chiTietPhieuMuas; }

    public List<BinhLuan> getBinhLuans() { return binhLuans; }
    public void setBinhLuans(List<BinhLuan> binhLuans) { this.binhLuans = binhLuans; }

    public List<SanPhamSize> getSanPhamSizes() { return sanPhamSizes; }
    public void setSanPhamSizes(List<SanPhamSize> sanPhamSizes) { this.sanPhamSizes = sanPhamSizes; }

    public ChiTietPhieuMua addChiTietPhieuMua(ChiTietPhieuMua c) {
        getChiTietPhieuMuas().add(c);
        c.setSanPham(this);
        return c;
    }
    public ChiTietPhieuMua removeChiTietPhieuMua(ChiTietPhieuMua c) {
        getChiTietPhieuMuas().remove(c);
        c.setSanPham(null);
        return c;
    }

    public BinhLuan addBinhLuan(BinhLuan b) {
        getBinhLuans().add(b);
        b.setSanPham(this);
        return b;
    }
    public BinhLuan removeBinhLuan(BinhLuan b) {
        getBinhLuans().remove(b);
        b.setSanPham(null);
        return b;
    }
}
