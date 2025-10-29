// filepath: src/main/java/vn/iotstar/DAO/ProductVariantDAO.java
package vn.iotstar.DAO;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.List;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.ProductVariant;

public class ProductVariantDAO {

    public void save(ProductVariant v) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (v.getVariantId() == null) em.persist(v); else em.merge(v);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public List<ProductVariant> findByProduct(Product product) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT v FROM ProductVariant v WHERE v.product = :p ORDER BY v.variantId DESC",
                    ProductVariant.class)
                .setParameter("p", product)
                .getResultList();
        } finally {
            em.close();
        }
    }

    public void delete(Long id) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            ProductVariant v = em.find(ProductVariant.class, id);
            if (v != null) em.remove(v);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** ✅ Tổng tồn kho của tất cả biến thể thuộc productId (nếu chưa có biến thể → 0). */
    public int sumStockByProductId(Long productId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            // SUM trên số nguyên trong JPA/Hibernate trả về Long
            Long total = em.createQuery(
                    "SELECT COALESCE(SUM(v.stock), 0) " +
                    "FROM ProductVariant v " +
                    "WHERE v.product.productId = :pid", Long.class)
                .setParameter("pid", productId)
                .getSingleResult();
            return total != null ? total.intValue() : 0;
        } finally {
            em.close();
        }
    }
}
