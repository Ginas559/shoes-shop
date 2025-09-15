package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.*;

@Entity
@Table(name = "SIZE")
@NamedQuery(name = "Size.findAll", query = "SELECT s FROM Size s")
public class Size implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MASIZE", length = 50)
    private String maSize;

    @Column(name = "TENSIZE", columnDefinition = "nvarchar(50)")
    private String tenSize;

    @OneToMany(mappedBy = "size", cascade = CascadeType.ALL)
    private List<SanPhamSize> sanPhamSizes = new ArrayList<>();

    public Size() {}

    public String getMaSize() { return maSize; }
    public void setMaSize(String maSize) { this.maSize = maSize; }
    public String getTenSize() { return tenSize; }
    public void setTenSize(String tenSize) { this.tenSize = tenSize; }

    public List<SanPhamSize> getSanPhamSizes() { return sanPhamSizes; }
    public void setSanPhamSizes(List<SanPhamSize> sanPhamSizes) { this.sanPhamSizes = sanPhamSizes; }
}
