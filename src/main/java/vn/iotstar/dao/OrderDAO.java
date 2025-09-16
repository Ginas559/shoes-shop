package vn.iotstar.dao;

import java.util.List;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entity.Order;

public class OrderDAO {

    // Lấy tất cả đơn hàng
    public List<Order> findAll() {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Order> query = em.createQuery("SELECT o FROM Order o ORDER BY o.createdAt DESC", Order.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // Lấy đơn hàng theo ID
    public Order findById(int id) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.find(Order.class, id);
        } finally {
            em.close();
        }
    }

    // Lấy các đơn hàng mới nhất, giới hạn số lượng
    public List<Order> findRecentOrders(int limit) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Order> query = em.createQuery(
                "SELECT o FROM Order o ORDER BY o.createdAt DESC", Order.class
            );
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
