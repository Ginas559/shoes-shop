package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "KHUYENMAI")
@NamedQuery(name = "KhuyenMai.findAll", query = "SELECT k FROM KhuyenMai k")
public class KhuyenMai implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAKM", length = 50)
    private String maKm;

    @Column(name = "TIEUDE", columnDefinition = "nvarchar(200)")
    private String tieuDe;

    @Column(name = "NGAYBD")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayBatDau;

    @Column(name = "NGAYKT")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayKetThuc;

    @Column(name = "PHANTRAM")
    private Double phanTram;

    // chi tiet khuyen mai (nhiều chi tiet cho 1 khuyen mai)
    @OneToMany(mappedBy = "khuyenMai", cascade = CascadeType.ALL)
    private List<ChiTietKhuyenMai> chiTietKhuyenMais = new ArrayList<>();

    public KhuyenMai() {}

    public String getMaKm() { return maKm; }
    public void setMaKm(String maKm) { this.maKm = maKm; }
    public String getTieuDe() { return tieuDe; }
    public void setTieuDe(String tieuDe) { this.tieuDe = tieuDe; }
    public Date getNgayBatDau() { return ngayBatDau; }
    public void setNgayBatDau(Date ngayBatDau) { this.ngayBatDau = ngayBatDau; }
    public Date getNgayKetThuc() { return ngayKetThuc; }
    public void setNgayKetThuc(Date ngayKetThuc) { this.ngayKetThuc = ngayKetThuc; }
    public Double getPhanTram() { return phanTram; }
    public void setPhanTram(Double phanTram) { this.phanTram = phanTram; }

    public List<ChiTietKhuyenMai> getChiTietKhuyenMais() { return chiTietKhuyenMais; }
    public void setChiTietKhuyenMais(List<ChiTietKhuyenMai> chiTietKhuyenMais) { this.chiTietKhuyenMais = chiTietKhuyenMais; }
}
