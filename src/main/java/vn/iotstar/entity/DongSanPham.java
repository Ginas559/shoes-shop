package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "DONGSANPHAM")
@NamedQuery(name = "DongSanPham.findAll", query = "SELECT d FROM DongSanPham d")
public class DongSanPham implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MADONGSANPHAM", length = 50)
    private String maDong;

    @Column(name = "TENDONG", columnDefinition = "nvarchar(200)")
    private String tenDong;

    @OneToMany(mappedBy = "dongSanPham", cascade = CascadeType.ALL)
    private List<SanPham> sanPhams = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "LoaiId", nullable = false) // tên cột FK trong bảng DONGSANPHAM
    private Loai loai;

    public Loai getLoai() {
        return loai;
    }

    public void setLoai(Loai loai) {
        this.loai = loai;
    }
    
    public DongSanPham() {}

    public String getMaDong() { return maDong; }
    public void setMaDong(String maDong) { this.maDong = maDong; }
    public String getTenDong() { return tenDong; }
    public void setTenDong(String tenDong) { this.tenDong = tenDong; }

    public List<SanPham> getSanPhams() { return sanPhams; }
    public void setSanPhams(List<SanPham> sanPhams) { this.sanPhams = sanPhams; }
}
