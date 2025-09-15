package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "VOUCHER")
@NamedQuery(name = "Voucher.findAll", query = "SELECT v FROM Voucher v")
public class Voucher implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAVOUCHER", length = 50)
    private String maVoucher;

    @Column(name = "SOLUTION", columnDefinition = "nvarchar(200)")
    private String solution;

    @Column(name = "GIATRI")
    private Double giaTri;

    @Column(name = "NGAYBD")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayBd;

    @Column(name = "NGAYKT")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayKt;

    @OneToMany(mappedBy = "voucher", cascade = CascadeType.ALL)
    private List<PhieuMua> phieuMuas = new ArrayList<>();

    public Voucher() {}

    public String getMaVoucher() { return maVoucher; }
    public void setMaVoucher(String maVoucher) { this.maVoucher = maVoucher; }
    public String getSolution() { return solution; }
    public void setSolution(String solution) { this.solution = solution; }
    public Double getGiaTri() { return giaTri; }
    public void setGiaTri(Double giaTri) { this.giaTri = giaTri; }
    public Date getNgayBd() { return ngayBd; }
    public void setNgayBd(Date ngayBd) { this.ngayBd = ngayBd; }
    public Date getNgayKt() { return ngayKt; }
    public void setNgayKt(Date ngayKt) { this.ngayKt = ngayKt; }

    public List<PhieuMua> getPhieuMuas() { return phieuMuas; }
    public void setPhieuMuas(List<PhieuMua> phieuMuas) { this.phieuMuas = phieuMuas; }
}
