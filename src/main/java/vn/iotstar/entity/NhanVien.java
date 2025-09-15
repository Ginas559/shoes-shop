package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "NHANVIEN")
@NamedQuery(name = "NhanVien.findAll", query = "SELECT n FROM NhanVien n")
public class NhanVien implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MANV", length = 50)
    private String maNv;

    @Column(name = "TENNV", columnDefinition = "nvarchar(200)")
    private String tenNv;

    @Column(name = "EMAIL", length = 200)
    private String email;

    @Column(name = "DIACHI", columnDefinition = "nvarchar(255)")
    private String diaChi;

    @Column(name = "SDT", length = 50)
    private String sdt;

    // 1 nhan vien co the xu ly nhieu phieu mua
    @OneToMany(mappedBy = "nhanVien", cascade = CascadeType.ALL)
    private List<PhieuMua> phieuMuas = new ArrayList<>();

    // nhan vien co tai khoan
    @OneToOne(mappedBy = "nhanVien", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private TaiKhoan taiKhoan;

    public NhanVien() {}

    public String getMaNv() { return maNv; }
    public void setMaNv(String maNv) { this.maNv = maNv; }
    public String getTenNv() { return tenNv; }
    public void setTenNv(String tenNv) { this.tenNv = tenNv; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }
    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }

    public List<PhieuMua> getPhieuMuas() { return phieuMuas; }
    public void setPhieuMuas(List<PhieuMua> phieuMuas) { this.phieuMuas = phieuMuas; }

    public TaiKhoan getTaiKhoan() { return taiKhoan; }
    public void setTaiKhoan(TaiKhoan taiKhoan) { this.taiKhoan = taiKhoan; }
}
