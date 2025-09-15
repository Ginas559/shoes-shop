package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "PHIEUMUA")
@NamedQuery(name = "PhieuMua.findAll", query = "SELECT p FROM PhieuMua p")
public class PhieuMua implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAPM", length = 50)
    private String maPm;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "NGAYDAT")
    private Date ngayDat;

    @Column(name = "TONGTIEN")
    private Double tongTien;

    @Column(name = "TINHTRANG", length = 50)
    private String tinhTrang;

    @Column(name = "DIACHIGIAOHANG", columnDefinition = "nvarchar(500)")
    private String diaChiGiaoHang;

    @Column(name = "MAKH", length = 50)
    private String maKh; // FK column

    @Column(name = "MAVOUCHER", length = 50)
    private String maVoucher;

    @Column(name = "MATT", length = 50) // ma phuong thuc thanh toan
    private String maPhuongThuc;

    @Column(name = "MANV", length = 50) // nhan vien xu ly
    private String maNv;

    // many phieu mua -> one khach hang
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAKH", insertable=false, updatable=false)
    private KhachHang khachHang;

    // many phieu mua -> nhan vien
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MANV", insertable=false, updatable=false)
    private NhanVien nhanVien;

    // phieu mua co the dung voucher
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAVOUCHER", insertable=false, updatable=false)
    private Voucher voucher;

    // phieu mua su dung phuong thuc thanh toan
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MATT", insertable=false, updatable=false)
    private PhuongThucThanhToan phuongThucThanhToan;

    // chi tiet phieu mua
    @OneToMany(mappedBy = "phieuMua", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChiTietPhieuMua> chiTietPhieuMuas = new ArrayList<>();

    public PhieuMua() {}

    // getters / setters
    public String getMaPm() { return maPm; }
    public void setMaPm(String maPm) { this.maPm = maPm; }
    public Date getNgayDat() { return ngayDat; }
    public void setNgayDat(Date ngayDat) { this.ngayDat = ngayDat; }
    public Double getTongTien() { return tongTien; }
    public void setTongTien(Double tongTien) { this.tongTien = tongTien; }
    public String getTinhTrang() { return tinhTrang; }
    public void setTinhTrang(String tinhTrang) { this.tinhTrang = tinhTrang; }
    public String getDiaChiGiaoHang() { return diaChiGiaoHang; }
    public void setDiaChiGiaoHang(String diaChiGiaoHang) { this.diaChiGiaoHang = diaChiGiaoHang; }
    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }
    public String getMaVoucher() { return maVoucher; }
    public void setMaVoucher(String maVoucher) { this.maVoucher = maVoucher; }
    public String getMaPhuongThuc() { return maPhuongThuc; }
    public void setMaPhuongThuc(String maPhuongThuc) { this.maPhuongThuc = maPhuongThuc; }
    public String getMaNv() { return maNv; }
    public void setMaNv(String maNv) { this.maNv = maNv; }

    public KhachHang getKhachHang() { return khachHang; }
    public void setKhachHang(KhachHang khachHang) { this.khachHang = khachHang; }
    public NhanVien getNhanVien() { return nhanVien; }
    public void setNhanVien(NhanVien nhanVien) { this.nhanVien = nhanVien; }
    public Voucher getVoucher() { return voucher; }
    public void setVoucher(Voucher voucher) { this.voucher = voucher; }
    public PhuongThucThanhToan getPhuongThucThanhToan() { return phuongThucThanhToan; }
    public void setPhuongThucThanhToan(PhuongThucThanhToan p) { this.phuongThucThanhToan = p; }
    public List<ChiTietPhieuMua> getChiTietPhieuMuas() { return chiTietPhieuMuas; }
    public void setChiTietPhieuMuas(List<ChiTietPhieuMua> chiTietPhieuMuas) { this.chiTietPhieuMuas = chiTietPhieuMuas; }

    public ChiTietPhieuMua addChiTiet(ChiTietPhieuMua c) {
        getChiTietPhieuMuas().add(c);
        c.setPhieuMua(this);
        return c;
    }
    public ChiTietPhieuMua removeChiTiet(ChiTietPhieuMua c) {
        getChiTietPhieuMuas().remove(c);
        c.setPhieuMua(null);
        return c;
    }
}
