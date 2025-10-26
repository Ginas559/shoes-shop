// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorShopServlet.java
package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import jakarta.persistence.*;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.configs.CloudinaryConfig;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {
    "/vendor/shop",          // xem/sửa hồ sơ shop
    "/vendor/shop/create",   // tạo shop lần đầu
    "/vendor/shop/update"    // cập nhật tên + logo
})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // giống VendorProductServlet
public class VendorShopServlet extends HttpServlet {

  // --- helper: tìm shop theo vendor đang đăng nhập (anti-IDOR) ---
  private Shop findMyShop(EntityManager em, Long vendorId) {
    TypedQuery<Shop> q = em.createQuery(
        "SELECT s FROM Shop s WHERE s.vendor.id = :vid", Shop.class);
    q.setParameter("vid", vendorId);
    return q.getResultStream().findFirst().orElse(null);
  }

  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String path = req.getServletPath(); // /vendor/shop | /vendor/shop/create | /vendor/shop/update
    if ("/vendor/shop/create".equals(path)) {
      req.getRequestDispatcher("/WEB-INF/views/vendor/shop-create.jsp").forward(req, resp);
      return;
    }

    // Mặc định là trang hồ sơ shop
    Long uid = SessionUtil.currentUserId(req);
    EntityManager em = JPAConfig.getEntityManager();
    try {
      Shop shop = findMyShop(em, uid);
      if (shop == null) {
        resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
        return;
      }
      req.setAttribute("shop", shop);
      req.getRequestDispatcher("/WEB-INF/views/vendor/shop-profile.jsp").forward(req, resp);
    } finally {
      em.close();
    }
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String path = req.getServletPath();
    if ("/vendor/shop/create".equals(path)) {
      handleCreate(req, resp);
      return;
    }
    if ("/vendor/shop/update".equals(path)) {
      handleUpdate(req, resp);
      return;
    }
    resp.sendRedirect(req.getContextPath() + "/vendor/shop");
  }

  // --- tạo shop lần đầu (giữ nguyên logic cũ) ---
  private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    Long uid = SessionUtil.currentUserId(req);
    String name = req.getParameter("shopName");
    String desc = req.getParameter("description");

    EntityManager em = JPAConfig.getEntityManager();
    EntityTransaction tx = em.getTransaction();
    try {
      tx.begin();

      // nếu đã có shop thì chuyển sang trang hồ sơ
      Shop existing = findMyShop(em, uid);
      if (existing != null) {
        tx.rollback();
        resp.sendRedirect(req.getContextPath() + "/vendor/shop");
        return;
      }

      Shop s = Shop.builder()
          .shopName(name)
          .description(desc)
          .status(Shop.ShopStatus.ACTIVE)
          .vendor(em.getReference(User.class, uid))
          .build();
      em.persist(s);
      tx.commit();
      resp.sendRedirect(req.getContextPath() + "/vendor/shop");
    } catch (Exception e) {
      if (tx.isActive()) tx.rollback();
      throw new ServletException(e);
    } finally {
      em.close();
    }
  }

  // --- cập nhật tên + logo shop của chính vendor ---
  private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    Long uid = SessionUtil.currentUserId(req);
    String name = req.getParameter("shopName");
    String desc = req.getParameter("description");
    Part logo = req.getPart("logo"); // optional

    EntityManager em = JPAConfig.getEntityManager();
    EntityTransaction tx = em.getTransaction();
    try {
      tx.begin();

      Shop shop = findMyShop(em, uid);
      if (shop == null) {
        tx.rollback();
        resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
        return;
      }

      shop.setShopName(name);
      shop.setDescription(desc);

      if (logo != null && logo.getSize() > 0) {
        Cloudinary cloud = CloudinaryConfig.getCloudinary();
        try (InputStream is = logo.getInputStream()) {
          byte[] data = is.readAllBytes();
          Map<?, ?> res = cloud.uploader().upload(
              data,
              ObjectUtils.asMap(
                  "folder", "shoes-shop/shops/" + shop.getShopId(),
                  "resource_type", "image",
                  "use_filename", true,
                  "unique_filename", true
              )
          );
          String url = String.valueOf(res.get("secure_url"));
          shop.setLogoUrl(url); // giữ nguyên ảnh cũ trên Cloudinary (không xóa)
        }
      }

      em.merge(shop);
      tx.commit();
      resp.sendRedirect(req.getContextPath() + "/vendor/shop");
    } catch (Exception e) {
      if (tx.isActive()) tx.rollback();
      throw new ServletException(e);
    } finally {
      em.close();
    }
  }
}
