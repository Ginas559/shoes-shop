// filepath: src/main/java/vn/iotstar/dao/ShoeAttributeDAO.java
package vn.iotstar.DAO;

import jakarta.persistence.*;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.ShoeAttribute;
import vn.iotstar.entities.Product;

public class ShoeAttributeDAO {

    public ShoeAttribute findByProduct(Product product) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT s FROM ShoeAttribute s WHERE s.product = :p", ShoeAttribute.class)
                .setParameter("p", product)
                .getResultStream()
                .findFirst().orElse(null);
        } finally {
            em.close();
        }
    }

    public void saveOrUpdate(ShoeAttribute attr) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (attr.getAttrId() == null)
                em.persist(attr);
            else
                em.merge(attr);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
