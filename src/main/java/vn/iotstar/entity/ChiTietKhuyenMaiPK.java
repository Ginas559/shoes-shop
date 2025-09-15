package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class ChiTietKhuyenMaiPK implements Serializable {
    private static final long serialVersionUID = 1L;

    @Column(name = "MAKM", length = 50)
    private String maKm;

    @Column(name = "MASP", length = 50)
    private String maSp;

    public ChiTietKhuyenMaiPK() {}

    public String getMaKm() { return maKm; }
    public void setMaKm(String maKm) { this.maKm = maKm; }
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ChiTietKhuyenMaiPK)) return false;
        ChiTietKhuyenMaiPK that = (ChiTietKhuyenMaiPK) o;
        return Objects.equals(maKm, that.maKm) && Objects.equals(maSp, that.maSp);
    }
    @Override
    public int hashCode() { return Objects.hash(maKm, maSp); }
}
