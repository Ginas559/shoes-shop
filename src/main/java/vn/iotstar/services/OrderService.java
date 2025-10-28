// src/main/java/vn/iotstar/services/OrderService.java

package vn.iotstar.services;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import java.util.List;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Order;

public class OrderService {

    public List<Order> getOrdersByStatus(Long shopId, String statusNullable) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            if (statusNullable == null || statusNullable.isBlank()) {
                return em.createQuery(
                                "SELECT o FROM Order o " +
                                        "JOIN FETCH o.user u " +
                                        "WHERE o.shop.shopId = :sid " +
                                        "ORDER BY o.createdAt DESC", Order.class)
                        .setParameter("sid", shopId)
                        .getResultList();
            } else {
                Order.OrderStatus st = Order.OrderStatus.valueOf(statusNullable);
                return em.createQuery(
                                "SELECT o FROM Order o " +
                                        "JOIN FETCH o.user u " +
                                        "WHERE o.shop.shopId = :sid AND o.status = :st " +
                                        "ORDER BY o.createdAt DESC", Order.class)
                        .setParameter("sid", shopId)
                        .setParameter("st", st)
                        .getResultList();
            }
        } finally {
            em.close();
        }
    }

    public void updateStatus(Long orderId, String newStatus) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order o = em.find(Order.class, orderId);
            if (o == null) throw new RuntimeException("Không tìm thấy đơn hàng");
            o.setStatus(Order.OrderStatus.valueOf(newStatus));
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Lấy 1 đơn hàng theo ID, nạp sẵn quan hệ để dùng ngay trong servlet/JSP. */
    public Order findById(Long orderId) {
        if (orderId == null) return null;
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT o FROM Order o " +
                                    "JOIN FETCH o.shop s " +
                                    "JOIN FETCH o.user u " +
                                    "WHERE o.orderId = :id", Order.class)
                    .setParameter("id", orderId)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    /** Ràng buộc đơn thuộc đúng shop. */
    public Order findByIdForShop(Long orderId, Long shopId) {
        if (orderId == null || shopId == null) return null;
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT o FROM Order o " +
                                    "JOIN FETCH o.shop s " +
                                    "JOIN FETCH o.user u " +
                                    "WHERE o.orderId = :id AND s.shopId = :sid", Order.class)
                    .setParameter("id", orderId)
                    .setParameter("sid", shopId)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }
}