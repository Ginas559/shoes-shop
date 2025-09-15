package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class SanPhamSizePK implements Serializable {
    private static final long serialVersionUID = 1L;

    @Column(name = "MASP", length = 50)
    private String maSp;

    @Column(name = "MASIZE", length = 50)
    private String maSize;

    public SanPhamSizePK() {}

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }
    public String getMaSize() { return maSize; }
    public void setMaSize(String maSize) { this.maSize = maSize; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SanPhamSizePK)) return false;
        SanPhamSizePK that = (SanPhamSizePK) o;
        return Objects.equals(maSp, that.maSp) && Objects.equals(maSize, that.maSize);
    }
    @Override
    public int hashCode() { return Objects.hash(maSp, maSize); }
}
