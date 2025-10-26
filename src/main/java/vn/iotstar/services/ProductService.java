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

    /**
     * Danh sách sản phẩm của vendor (dùng trong trang quản trị vendor).
     * Đã JOIN FETCH shop để tránh Lazy khi hiển thị shopName.
     */
    public List<Product> getByVendor(HttpServletRequest req) {
        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) return List.of();
        Shop shop = helper.findShopByOwner(uid);
        if (shop == null) return List.of();

        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT p FROM Product p " +
                "JOIN FETCH p.shop s " +
                "WHERE s.shopId = :sid " +
                "ORDER BY p.productId DESC",
                Product.class
            ).setParameter("sid", shop.getShopId())
             .getResultList();
        } finally { em.close(); }
    }

    /** Tạo product mới và TRẢ VỀ productId để servlet còn lưu ảnh. */
    public Long add(HttpServletRequest req) {
        Long uid = SessionUtil.currentUserId(req);
        if (uid == null) throw new RuntimeException("Chưa đăng nhập");

        Shop shop = helper.findShopByOwner(uid);
        if (shop == null) throw new RuntimeException("Shop không tồn tại cho vendor");

        String name    = req.getParameter("name");
        String priceStr= req.getParameter("price");
        String stockStr= req.getParameter("stock");
        String catStr  = req.getParameter("categoryId");

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
            throw new RuntimeException("Giá/ tồn/ danh mục không hợp lệ", ex);
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
            em.flush(); // đảm bảo có id
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

    /** Lấy 1 product (KHÔNG JOIN shop) – GIỮ NGUYÊN để không phá chỗ khác. */
    public Product findById(Long id) {
        EntityManager em = JPAConfig.getEntityManager();
        try { return em.find(Product.class, id); }
        finally { em.close(); }
    }

    /** Lấy 1 product KÈM shop để render detail.jsp hiển thị shopName. */
    public Product findByIdWithShop(Long id) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT p FROM Product p " +
                "JOIN FETCH p.shop " +
                "WHERE p.productId = :id",
                Product.class
            ).setParameter("id", id)
             .getSingleResult();
        } finally { em.close(); }
    }

    /** List sản phẩm ACTIVE kèm shop để render list.jsp (có phân trang). */
    public List<Product> findActiveWithShop(int page, int size) {
        int first = Math.max(0, page) * Math.max(1, size);
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                "SELECT p FROM Product p " +
                "JOIN FETCH p.shop " +
                "WHERE p.status = :st " +
                "ORDER BY p.productId DESC",
                Product.class
            ).setParameter("st", Product.ProductStatus.ACTIVE)
             .setFirstResult(first)
             .setMaxResults(size)
             .getResultList();
        } finally { em.close(); }
    }

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
        } finally { em.close(); }
    }

    /** Xoá mềm: chuyển INACTIVE */
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
        } finally { em.close(); }
    }
}
