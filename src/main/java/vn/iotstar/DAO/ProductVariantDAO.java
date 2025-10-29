// filepath: src/main/java/vn/iotstar/dao/ProductVariantDAO.java
package vn.iotstar.DAO;

import java.util.List;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.ProductVariant;

public class ProductVariantDAO {

    public void save(ProductVariant variant) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(variant);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public List<ProductVariant> findByProduct(Product product) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT v FROM ProductVariant v WHERE v.product = :p", ProductVariant.class)
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
            ProductVariant pv = em.find(ProductVariant.class, id);
            if (pv != null) em.remove(pv);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
