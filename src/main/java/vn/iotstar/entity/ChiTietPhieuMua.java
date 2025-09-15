package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "CHITIETPHIEUMUA")
@NamedQuery(name = "ChiTietPhieuMua.findAll", query = "SELECT c FROM ChiTietPhieuMua c")
public class ChiTietPhieuMua implements Serializable {
    private static final long serialVersionUID = 1L;

    @EmbeddedId
    private ChiTietPhieuMuaPK id = new ChiTietPhieuMuaPK();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maPm")
    @JoinColumn(name = "MAPM", nullable = false)
    private PhieuMua phieuMua;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maSp")
    @JoinColumn(name = "MASP", nullable = false)
    private SanPham sanPham;

    @Column(name = "SOLUONG")
    private Integer soLuong;

    @Column(name = "DONGIA")
    private Double donGia;

    public ChiTietPhieuMua() {}

    public ChiTietPhieuMuaPK getId() { return id; }
    public void setId(ChiTietPhieuMuaPK id) { this.id = id; }
    public PhieuMua getPhieuMua() { return phieuMua; }
    public void setPhieuMua(PhieuMua phieuMua) { this.phieuMua = phieuMua; }
    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }
    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }
    public Double getDonGia() { return donGia; }
    public void setDonGia(Double donGia) { this.donGia = donGia; }
}
