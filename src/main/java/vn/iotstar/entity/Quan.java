package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "QUAN")
@NamedQuery(name = "Quan.findAll", query = "SELECT q FROM Quan q")
public class Quan implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAQUAN", length = 50)
    private String maQuan;

    @Column(name = "TENQUAN", columnDefinition = "nvarchar(200)")
    private String tenQuan;

    @Column(name = "MATINH", length = 50)
    private String maTinh;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MATINH", insertable=false, updatable=false)
    private Tinh tinh;

    @OneToMany(mappedBy = "quan", cascade = CascadeType.ALL)
    private List<Phuong> phuongs = new ArrayList<>();

    public Quan() {}

    public String getMaQuan() { return maQuan; }
    public void setMaQuan(String maQuan) { this.maQuan = maQuan; }
    public String getTenQuan() { return tenQuan; }
    public void setTenQuan(String tenQuan) { this.tenQuan = tenQuan; }
    public String getMaTinh() { return maTinh; }
    public void setMaTinh(String maTinh) { this.maTinh = maTinh; }

    public Tinh getTinh() { return tinh; }
    public void setTinh(Tinh tinh) { this.tinh = tinh; }

    public List<Phuong> getPhuongs() { return phuongs; }
    public void setPhuongs(List<Phuong> phuongs) { this.phuongs = phuongs; }
}
