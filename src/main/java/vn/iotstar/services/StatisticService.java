// src/main/java/vn/iotstar/services/StatisticService.java

package vn.iotstar.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Order;
import vn.iotstar.entities.Shop;

public class StatisticService {

    /* =============================
     * SHOP RESOLVERS
     * ============================= */

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
        } finally {
            em.close();
        }
    }

    public Shop findShopById(Long shopId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.find(Shop.class, shopId);
        } finally {
            em.close();
        }
    }

    /* =============================
     * DASHBOARD (with optional date-range filters)
     * ============================= */

    public Map<String, Object> getDashboardData(Long shopId) {
        // giữ nguyên: tổng quan không filter theo thời gian
        EntityManager em = JPAConfig.getEntityManager();
        try {
            Long orderCount = em.createQuery(
                            "SELECT COUNT(o) FROM Order o WHERE o.shop.shopId = :sid", Long.class)
                    .setParameter("sid", shopId)
                    .getSingleResult();

            // Doanh thu CHỈ tính đơn đã giao thành công
            BigDecimal totalRevenueDelivered = em.createQuery(
                            "SELECT COALESCE(SUM(o.totalAmount),0) FROM Order o " +
                                    "WHERE o.shop.shopId = :sid AND o.status = :st", BigDecimal.class)
                    .setParameter("sid", shopId)
                    .setParameter("st", Order.OrderStatus.DELIVERED)
                    .getSingleResult();

            List<Object[]> topProducts = em.createQuery(
                            "SELECT oi.product.productName, SUM(oi.quantity) AS qty " +
                                    "FROM OrderItem oi " +
                                    "WHERE oi.order.shop.shopId = :sid AND oi.order.status = :st " +
                                    "GROUP BY oi.product.productName ORDER BY qty DESC", Object[].class)
                    .setParameter("sid", shopId)
                    .setParameter("st", Order.OrderStatus.DELIVERED)
                    .setMaxResults(5)
                    .getResultList();

            Map<String, Object> m = new HashMap<>();
            m.put("orderCount", orderCount);
            m.put("revenue", totalRevenueDelivered);
            m.put("topProducts", topProducts);
            return m;
        } finally {
            em.close();
        }
    }

    /* =============================
     * REVENUE BY MONTH  (filter by year or by [from,to])
     * ============================= */

    public List<Object[]> getRevenueByMonth(Long shopId) {
        // legacy (không filter năm) – vẫn giữ để tương thích
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT FUNCTION('MONTH', o.createdAt), COALESCE(SUM(o.totalAmount),0) " +
                                    "FROM Order o WHERE o.shop.shopId = :sid AND o.status = :st " +
                                    "GROUP BY FUNCTION('MONTH', o.createdAt) " +
                                    "ORDER BY FUNCTION('MONTH', o.createdAt)", Object[].class)
                    .setParameter("sid", shopId)
                    .setParameter("st", Order.OrderStatus.DELIVERED)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Doanh thu theo tháng với tuỳ chọn năm hoặc khoảng ngày. Ưu tiên from/to nếu có. */
    public List<Object[]> getRevenueByMonth(Long shopId, Integer year, LocalDate from, LocalDate to) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            if (from != null && to != null) {
                LocalDateTime start = from.atStartOfDay();
                LocalDateTime end = to.plusDays(1).atStartOfDay(); // inclusive
                return em.createQuery(
                                "SELECT FUNCTION('MONTH', o.createdAt), COALESCE(SUM(o.totalAmount),0) " +
                                        "FROM Order o " +
                                        "WHERE o.shop.shopId = :sid AND o.status = :st " +
                                        "AND o.createdAt >= :start AND o.createdAt < :end " +
                                        "GROUP BY FUNCTION('MONTH', o.createdAt) " +
                                        "ORDER BY FUNCTION('MONTH', o.createdAt)", Object[].class)
                        .setParameter("sid", shopId)
                        .setParameter("st", Order.OrderStatus.DELIVERED)
                        .setParameter("start", start)
                        .setParameter("end", end)
                        .getResultList();
            }
            if (year != null) {
                return em.createQuery(
                                "SELECT FUNCTION('MONTH', o.createdAt), COALESCE(SUM(o.totalAmount),0) " +
                                        "FROM Order o " +
                                        "WHERE o.shop.shopId = :sid AND o.status = :st " +
                                        "AND FUNCTION('YEAR', o.createdAt) = :y " +
                                        "GROUP BY FUNCTION('MONTH', o.createdAt) " +
                                        "ORDER BY FUNCTION('MONTH', o.createdAt)", Object[].class)
                        .setParameter("sid", shopId)
                        .setParameter("st", Order.OrderStatus.DELIVERED)
                        .setParameter("y", year)
                        .getResultList();
            }
            return getRevenueByMonth(shopId);
        } finally {
            em.close();
        }
    }

    /* =============================
     * COUNT ORDERS BY STATUS (with optional date-range)
     * ============================= */

    public Map<Order.OrderStatus, Long> countOrdersByStatus(Long shopId, LocalDate from, LocalDate to) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            String jpql = "SELECT o.status, COUNT(o) FROM Order o " +
                          "WHERE o.shop.shopId = :sid " +
                          (from != null && to != null ?
                                  "AND o.createdAt >= :start AND o.createdAt < :end " : "") +
                          "GROUP BY o.status";
            TypedQuery<Object[]> q = em.createQuery(jpql, Object[].class)
                    .setParameter("sid", shopId);
            if (from != null && to != null) {
                q.setParameter("start", from.atStartOfDay());
                q.setParameter("end", to.plusDays(1).atStartOfDay());
            }
            List<Object[]> rows = q.getResultList();
            Map<Order.OrderStatus, Long> map = new EnumMap<>(Order.OrderStatus.class);
            for (Object[] r : rows) {
                map.put((Order.OrderStatus) r[0], (Long) r[1]);
            }
            return map;
        } finally {
            em.close();
        }
    }

    /* =============================
     * RECENT ORDERS
     * ============================= */

    public List<Order> findRecentOrders(Long shopId, int limit) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT o FROM Order o " +
                                    "JOIN FETCH o.user u " +
                                    "WHERE o.shop.shopId = :sid " +
                                    "ORDER BY o.createdAt DESC", Order.class)
                    .setParameter("sid", shopId)
                    .setMaxResults(Math.max(1, limit))
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /* =============================
     * MOM GROWTH (%)
     * ============================= */

    public BigDecimal calcMonthOverMonthGrowth(Long shopId, YearMonth current) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            YearMonth prev = current.minusMonths(1);

            BigDecimal cur = sumRevenueInMonth(em, shopId, current);
            BigDecimal pre = sumRevenueInMonth(em, shopId, prev);

            if (pre == null || pre.compareTo(BigDecimal.ZERO) == 0) {
                return (cur != null && cur.compareTo(BigDecimal.ZERO) > 0)
                        ? BigDecimal.valueOf(100) // coi như tăng từ 0 → có
                        : BigDecimal.ZERO;
            }
            return cur.subtract(pre)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(pre, 2, java.math.RoundingMode.HALF_UP);
        } finally {
            em.close();
        }
    }

    private BigDecimal sumRevenueInMonth(EntityManager em, Long shopId, YearMonth ym) {
        LocalDateTime start = ym.atDay(1).atStartOfDay();
        LocalDateTime end = ym.plusMonths(1).atDay(1).atStartOfDay();
        return em.createQuery(
                        "SELECT COALESCE(SUM(o.totalAmount),0) FROM Order o " +
                                "WHERE o.shop.shopId = :sid AND o.status = :st " +
                                "AND o.createdAt >= :start AND o.createdAt < :end", BigDecimal.class)
                .setParameter("sid", shopId)
                .setParameter("st", Order.OrderStatus.DELIVERED)
                .setParameter("start", start)
                .setParameter("end", end)
                .getSingleResult();
    }
}