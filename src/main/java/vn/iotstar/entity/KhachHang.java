package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "KHACHHANG")
@NamedQuery(name = "KhachHang.findAll", query = "SELECT k FROM KhachHang k")
public class KhachHang implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAKH", length = 50)
    private String maKh;

    @Column(name = "TENKH", columnDefinition = "nvarchar(200)")
    private String tenKh;

    @Column(name = "EMAIL", length = 200)
    private String email;

    @Column(name = "SDT", length = 50)
    private String sdt;

    @Column(name = "DIACHI", columnDefinition = "nvarchar(500)")
    private String diaChi;

    @Column(name = "MATKHAU", length = 200)
    private String matKhau;

    // 1 khach hang co nhieu phieu mua
    @OneToMany(mappedBy = "khachHang", cascade = CascadeType.ALL)
    private List<PhieuMua> phieuMuas = new ArrayList<>();

    // 1 khach hang co nhieu dia chi
    @OneToMany(mappedBy = "khachHang", cascade = CascadeType.ALL)
    private List<SoDiaChi> diaChis = new ArrayList<>();

    public KhachHang() {}

    // getters / setters
    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }
    public String getTenKh() { return tenKh; }
    public void setTenKh(String tenKh) { this.tenKh = tenKh; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }
    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }
    public String getMatKhau() { return matKhau; }
    public void setMatKhau(String matKhau) { this.matKhau = matKhau; }

    public List<PhieuMua> getPhieuMuas() { return phieuMuas; }
    public void setPhieuMuas(List<PhieuMua> phieuMuas) { this.phieuMuas = phieuMuas; }

    public List<SoDiaChi> getDiaChis() { return diaChis; }
    public void setDiaChis(List<SoDiaChi> diaChis) { this.diaChis = diaChis; }

    public PhieuMua addPhieuMua(PhieuMua p) {
        getPhieuMuas().add(p);
        p.setKhachHang(this);
        return p;
    }
    public PhieuMua removePhieuMua(PhieuMua p) {
        getPhieuMuas().remove(p);
        p.setKhachHang(null);
        return p;
    }
}
