package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "TAIKHOAN")
@NamedQuery(name = "TaiKhoan.findAll", query = "SELECT t FROM TaiKhoan t")
public class TaiKhoan implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "EMAIL", length = 200)
    private String email;

    @Column(name = "MATKHAU", length = 200)
    private String matKhau;

    @Column(name = "ROLE", length = 50)
    private String role;

    @Column(name = "MANV", length = 50)
    private String maNv;

    // tai khoan -> nhan vien (neu co)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MANV", insertable=false, updatable=false)
    private NhanVien nhanVien;

    public TaiKhoan() {}

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getMatKhau() { return matKhau; }
    public void setMatKhau(String matKhau) { this.matKhau = matKhau; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getMaNv() { return maNv; }
    public void setMaNv(String maNv) { this.maNv = maNv; }

    public NhanVien getNhanVien() { return nhanVien; }
    public void setNhanVien(NhanVien nhanVien) { this.nhanVien = nhanVien; }
}
