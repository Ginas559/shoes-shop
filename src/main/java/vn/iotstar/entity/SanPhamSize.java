package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "SANPHAMSIZE")
@NamedQuery(name = "SanPhamSize.findAll", query = "SELECT s FROM SanPhamSize s")
public class SanPhamSize implements Serializable {
    private static final long serialVersionUID = 1L;

    @EmbeddedId
    private SanPhamSizePK id = new SanPhamSizePK();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maSp")
    @JoinColumn(name = "MASP", nullable = false, columnDefinition = "varchar(50)")
    private SanPham sanPham;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("maSize")
    @JoinColumn(name = "MASIZE", nullable = false, columnDefinition = "varchar(50)")
    private Size size;

    @Column(name = "SOLUONG")
    private Integer soLuong;

    public SanPhamSize() {}

    public SanPhamSizePK getId() { return id; }
    public void setId(SanPhamSizePK id) { this.id = id; }
    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }
    public Size getSize() { return size; }
    public void setSize(Size size) { this.size = size; }
    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }
}
