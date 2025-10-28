package vn.iotstar.DAO.Impl;

import java.util.List;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import vn.iotstar.DAO.IOrderDao;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Category;
import vn.iotstar.entities.Order.OrderStatus;
import vn.iotstar.entities.Order;
import vn.iotstar.entities.Shop;

public class OrderDaoImpl implements IOrderDao {
	
	@Override
	public List<Order> searchOrders(OrderStatus status, Shop shop, Category category, int page, int pageSize) {
		EntityManager em = JPAConfig.getEntityManager();
		try {
			String jpql = "SELECT o FROM Order o WHERE 1=1";
			
			if (status != null) {
				jpql += " AND o.status = :status";
			}

			if (shop != null) {
				jpql += " AND o.shop = :shop";
			}

			if (category != null) {
				jpql += " AND o.category = :category";
			}

			TypedQuery<Order> query = em.createQuery(jpql, Order.class);

			
			if (status != null) {
				query.setParameter("status", status);
			}

			if (shop != null) {
				query.setParameter("shop", shop);
			}

			if (category != null) {
				query.setParameter("category", category);
			}

			query.setFirstResult((page - 1) * pageSize);
			query.setMaxResults(pageSize);

			return query.getResultList();
		} finally {
			em.close();
		}

	}
	
	@Override
	public int countOrders(OrderStatus status, Shop shop, Category category) {
		EntityManager em = JPAConfig.getEntityManager();
		try {
			String jpql = "SELECT COUNT(o) FROM Order o WHERE 1=1";

			if (status != null) {
				jpql += " AND o.status = :status";
			}

			if (shop != null) {
				jpql += " AND o.shop = :shop";
			}

			if (category != null) {
				jpql += " AND o.category = :category";
			}

			

			TypedQuery<Long> query = em.createQuery(jpql, Long.class);

			

			if (status != null) {
				query.setParameter("status", status);
			}

			if (shop != null) {
				query.setParameter("shop", shop);
			}

			if (category != null) {
				query.setParameter("category", category);
			}
			

			return query.getSingleResult().intValue();
		} finally {
			em.close();
		}
	}

	
}
