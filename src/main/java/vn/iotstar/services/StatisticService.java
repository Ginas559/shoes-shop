package vn.iotstar.services;

import java.math.BigDecimal;
import java.util.*;
import jakarta.persistence.*;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Shop;

public class StatisticService {

    public Map<String, Object> getDashboardData(Long shopId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            Long orderCount = em.createQuery(
                "SELECT COUNT(o) FROM Order o WHERE o.shop.shopId = :sid", Long.class)
                .setParameter("sid", shopId)
                .getSingleResult();

            BigDecimal totalRevenue = em.createQuery(
                "SELECT COALESCE(SUM(o.totalAmount),0) FROM Order o WHERE o.shop.shopId = :sid",
                BigDecimal.class)
                .setParameter("sid", shopId)
                .getSingleResult();

            List<Object[]> topProducts = em.createQuery(
                "SELECT oi.product.productName, SUM(oi.quantity) AS qty " +
                "FROM OrderItem oi WHERE oi.order.shop.shopId = :sid " +
                "GROUP BY oi.product.productName ORDER BY qty DESC", Object[].class)
                .setParameter("sid", shopId)
                .setMaxResults(5)
                .getResultList();

            Map<String,Object> m = new HashMap<>();
            m.put("orderCount", orderCount);
            m.put("revenue", totalRevenue);
            m.put("topProducts", topProducts);
            return m;
        } finally { em.close(); }
    }

    /** 1 vendor ↔ 1 shop */
    public Shop findShopByOwner(Long userId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            List<Shop> list = em.createQuery(
                "SELECT s FROM Shop s WHERE s.vendor.id = :uid", Shop.class)
                .setParameter("uid", userId)
                .setMaxResults(1)
                .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally { em.close(); }
    }

    public List<Object[]> getRevenueByMonth(Long shopId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT FUNCTION('MONTH', o.createdAt), COALESCE(SUM(o.totalAmount),0) " +
                "FROM Order o WHERE o.shop.shopId = :sid " +
                "GROUP BY FUNCTION('MONTH', o.createdAt) " +
                "ORDER BY FUNCTION('MONTH', o.createdAt)", Object[].class)
                .setParameter("sid", shopId)
                .getResultList();
        } finally { em.close(); }
    }
    
 // filepath: src/main/java/vn/iotstar/services/StatisticService.java
    public Shop findShopById(Long shopId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.find(Shop.class, shopId);
        } finally {
            em.close();
        }
    }

}
