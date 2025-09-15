package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "PHUONG")
@NamedQuery(name = "Phuong.findAll", query = "SELECT p FROM Phuong p")
public class Phuong implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MAPHUONG", length = 50)
    private String maPhuong;

    @Column(name = "TENPHUONG", columnDefinition = "nvarchar(200)")
    private String tenPhuong;

    @Column(name = "MAQUAN", length = 50)
    private String maQuan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAQUAN", insertable=false, updatable=false)
    private Quan quan;

    public Phuong() {}

    public String getMaPhuong() { return maPhuong; }
    public void setMaPhuong(String maPhuong) { this.maPhuong = maPhuong; }
    public String getTenPhuong() { return tenPhuong; }
    public void setTenPhuong(String tenPhuong) { this.tenPhuong = tenPhuong; }
    public String getMaQuan() { return maQuan; }
    public void setMaQuan(String maQuan) { this.maQuan = maQuan; }

    public Quan getQuan() { return quan; }
    public void setQuan(Quan quan) { this.quan = quan; }
}
