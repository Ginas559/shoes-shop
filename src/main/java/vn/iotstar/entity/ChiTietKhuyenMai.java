package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "CHITIETKHUYENMAI")
@NamedQuery(name = "ChiTietKhuyenMai.findAll", query = "SELECT c FROM ChiTietKhuyenMai c")
public class ChiTietKhuyenMai implements Serializable {
    private static final long serialVersionUID = 1L;

    @EmbeddedId
    private ChiTietKhuyenMaiPK id = new ChiTietKhuyenMaiPK();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maKm")
    @JoinColumn(name = "MAKM", nullable = false, columnDefinition = "varchar(50)")
    private KhuyenMai khuyenMai;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maSp")
    @JoinColumn(name = "MASP", nullable = false, columnDefinition = "varchar(50)")
    private SanPham sanPham;

    public ChiTietKhuyenMai() {}

    public ChiTietKhuyenMaiPK getId() { return id; }
    public void setId(ChiTietKhuyenMaiPK id) { this.id = id; }
    public KhuyenMai getKhuyenMai() { return khuyenMai; }
    public void setKhuyenMai(KhuyenMai khuyenMai) { this.khuyenMai = khuyenMai; }
    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }
}
