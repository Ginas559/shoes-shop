// src/main/java/vn/iotstar/services/ProductService.java
package vn.iotstar.services;

import java.math.BigDecimal;
import java.util.List;
import jakarta.persistence.*;
import jakarta.servlet.http.HttpServletRequest;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.Category;
import vn.iotstar.utils.SessionUtil;

public class ProductService {

    private final StatisticService helper = new StatisticService();

    /** Lấy danh sách sản phẩm của vendor hiện tại */
    public List<Product> getByVendor(HttpServletRequest req) {
        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) return List.of();

        Shop shop = helper.findShopByOwner(uid);
        if (shop == null) return List.of();

        EntityManager em = JPAConfig.getEntityManager();
        try {
            // JOIN FETCH để nạp sẵn quan hệ tránh lỗi LazyInitializationException
            return em.createQuery(
                "SELECT DISTINCT p FROM Product p " +
                "JOIN FETCH p.shop s " +
                "LEFT JOIN FETCH p.category c " +
                "WHERE s.shopId = :sid " +
                "ORDER BY p.productId DESC",
                Product.class
            )
            .setParameter("sid", shop.getShopId())
            .getResultList();
        } finally {
            em.close();
        }
    }

    /** Thêm sản phẩm mới và trả về ID của sản phẩm đó */
    public Long add(HttpServletRequest req) {
        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) throw new RuntimeException("Chưa đăng nhập");

        Shop shop = helper.findShopByOwner(uid);
        if (shop == null) throw new RuntimeException("Shop không tồn tại cho vendor");

        String name = req.getParameter("name");
        String priceStr = req.getParameter("price");
        String stockStr = req.getParameter("stock");
        String catStr = req.getParameter("categoryId");

        if (name == null || name.isBlank())
            throw new RuntimeException("Tên sản phẩm không được rỗng");
        if (catStr == null || catStr.isBlank())
            throw new RuntimeException("Vui lòng chọn danh mục");

        BigDecimal price;
        int stock;
        Long categoryId;

        try {
            price = new BigDecimal(priceStr);
            stock = Integer.parseInt(stockStr);
            categoryId = Long.valueOf(catStr);
        } catch (Exception ex) {
            throw new RuntimeException("Giá / tồn / danh mục không hợp lệ", ex);
        }

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            Product p = Product.builder()
                .productName(name)
                .price(price)
                .stock(stock)
                .status(Product.ProductStatus.ACTIVE)
                .shop(em.getReference(Shop.class, shop.getShopId()))
                .category(em.getReference(Category.class, categoryId))
                .build();

            em.persist(p);
            em.flush(); // đảm bảo có ID trước khi commit
            Long newId = p.getProductId();

            tx.commit();
            return newId;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Lấy chi tiết sản phẩm theo ID */
    public Product findById(Long id) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            // Nạp cả shop và category để dùng trong form edit
            return em.createQuery(
                "SELECT p FROM Product p " +
                "JOIN FETCH p.shop " +
                "LEFT JOIN FETCH p.category " +
                "WHERE p.productId = :id",
                Product.class
            )
            .setParameter("id", id)
            .getSingleResult();
        } finally {
            em.close();
        }
    }

    /** Cập nhật sản phẩm */
    public void update(HttpServletRequest req) {
        Long pid = Long.valueOf(req.getParameter("productId"));
        String name = req.getParameter("name");
        BigDecimal price = new BigDecimal(req.getParameter("price"));
        int stock = Integer.parseInt(req.getParameter("stock"));
        String status = req.getParameter("status");

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Product p = em.find(Product.class, pid);
            if (p == null) throw new RuntimeException("Không tìm thấy sản phẩm");
            p.setProductName(name);
            p.setPrice(price);
            p.setStock(stock);
            if (status != null && !status.isBlank()) {
                p.setStatus(Product.ProductStatus.valueOf(status));
            }
            em.merge(p);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Xoá mềm (ẩn sản phẩm) */
    public void softDelete(Long productId) {
        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Product p = em.find(Product.class, productId);
            if (p != null) {
                p.setStatus(Product.ProductStatus.INACTIVE);
                em.merge(p);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
