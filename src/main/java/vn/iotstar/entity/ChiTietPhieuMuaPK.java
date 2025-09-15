package vn.iotstar.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class ChiTietPhieuMuaPK implements Serializable {
    private static final long serialVersionUID = 1L;

    @Column(name = "MAPM", length = 50)
    private String maPm;

    @Column(name = "MASP", length = 50)
    private String maSp;

    public ChiTietPhieuMuaPK() {}

    public String getMaPm() { return maPm; }
    public void setMaPm(String maPm) { this.maPm = maPm; }
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ChiTietPhieuMuaPK)) return false;
        ChiTietPhieuMuaPK that = (ChiTietPhieuMuaPK) o;
        return Objects.equals(maPm, that.maPm) && Objects.equals(maSp, that.maSp);
    }
    @Override
    public int hashCode() { return Objects.hash(maPm, maSp); }
}
