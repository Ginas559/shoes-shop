package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "LOAI")
@NamedQuery(name = "Loai.findAll", query = "SELECT l FROM Loai l")
public class Loai implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MALOAISP", length = 50)
    private String maLoai;

    @Column(name = "TENLOAI", columnDefinition = "nvarchar(200)")
    private String tenLoai;

    // neu san pham co relation voi loai, thêm list
    @OneToMany(mappedBy = "loai", cascade = CascadeType.ALL)
    private List<DongSanPham> dongSanPhams = new ArrayList<>();

    public Loai() {}

    public String getMaLoai() { return maLoai; }
    public void setMaLoai(String maLoai) { this.maLoai = maLoai; }
    public String getTenLoai() { return tenLoai; }
    public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }

    public List<DongSanPham> getDongSanPhams() { return dongSanPhams; }
    public void setDongSanPhams(List<DongSanPham> dongSanPhams) { this.dongSanPhams = dongSanPhams; }
}
