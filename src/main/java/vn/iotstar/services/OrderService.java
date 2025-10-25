package vn.iotstar.services;

import java.util.List;
import jakarta.persistence.*;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Order;

public class OrderService {

    public List<Order> getOrdersByStatus(Long shopId, String statusNullable) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            if (statusNullable == null || statusNullable.isBlank()) {
                return em.createQuery(
                    "SELECT o FROM Order o " +
                    "JOIN FETCH o.user u " +                 // <- load sẵn user
                    "WHERE o.shop.shopId = :sid " +
                    "ORDER BY o.createdAt DESC", Order.class)
                    .setParameter("sid", shopId)
                    .getResultList();
            } else {
                Order.OrderStatus st = Order.OrderStatus.valueOf(statusNullable);
                return em.createQuery(
                    "SELECT o FROM Order o " +
                    "JOIN FETCH o.user u " +                 // <- load sẵn user
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
}
