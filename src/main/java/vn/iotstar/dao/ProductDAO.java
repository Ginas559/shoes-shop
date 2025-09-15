package vn.iotstar.dao;

import java.util.List;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entity.Product;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

public class ProductDAO {

    public List<Product> findTopProducts(int limit) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Product> query = em.createQuery(
                "SELECT p FROM Product p ORDER BY p.createdAt DESC",
                Product.class
            );
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
