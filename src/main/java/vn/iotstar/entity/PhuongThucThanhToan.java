package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "PHUONGTHUCTHANHTOAN")
@NamedQuery(name = "PhuongThucThanhToan.findAll", query = "SELECT p FROM PhuongThucThanhToan p")
public class PhuongThucThanhToan implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAPTT", length = 50)
    private String maPtt;

    @Column(name = "TENPHT", columnDefinition = "nvarchar(200)")
    private String tenPtt;

    @OneToMany(mappedBy = "phuongThucThanhToan", cascade = CascadeType.ALL)
    private List<PhieuMua> phieuMuas = new ArrayList<>();

    public PhuongThucThanhToan() {}

    public String getMaPtt() { return maPtt; }
    public void setMaPtt(String maPtt) { this.maPtt = maPtt; }
    public String getTenPtt() { return tenPtt; }
    public void setTenPtt(String tenPtt) { this.tenPtt = tenPtt; }

    public List<PhieuMua> getPhieuMuas() { return phieuMuas; }
    public void setPhieuMuas(List<PhieuMua> phieuMuas) { this.phieuMuas = phieuMuas; }
}
