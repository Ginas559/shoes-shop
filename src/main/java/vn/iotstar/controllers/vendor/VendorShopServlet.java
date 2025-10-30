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

import vn.iotstar.configs.CloudinaryConfig;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/shop", "/vendor/shop/create"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB
public class VendorShopServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String path = req.getServletPath();
    if ("/vendor/shop/create".equals(path)) {
      req.getRequestDispatcher("/WEB-INF/views/vendor/shop-create.jsp").forward(req, resp);
      return;
    }

    Long uid = SessionUtil.currentUserId(req);
    EntityManager em = JPAConfig.getEntityManager();
    try {
      // So sánh entity thay vì truy cập field id
      User vendorRef = em.getReference(User.class, uid);
      Shop shop = em.createQuery(
              "SELECT s FROM Shop s WHERE s.vendor = :vendor", Shop.class)
          .setParameter("vendor", vendorRef)
          .getSingleResult();

      req.setAttribute("shop", shop);
      req.getRequestDispatcher("/WEB-INF/views/vendor/shop-profile.jsp").forward(req, resp);
    } catch (NoResultException e) {
      resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
    } finally {
      em.close();
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    Long uid = SessionUtil.currentUserId(req);
    EntityManager em = JPAConfig.getEntityManager();
    EntityTransaction tx = em.getTransaction();

    try {
      User vendorRef = em.getReference(User.class, uid); 
      Shop shop = em.createQuery(
              "SELECT s FROM Shop s WHERE s.vendor = :vendor", Shop.class)
          .setParameter("vendor", vendorRef)
          .getSingleResult();

      String name = req.getParameter("shopName");
      String desc = req.getParameter("description");
      if (name != null) shop.setShopName(name.trim());
      if (desc != null) shop.setDescription(desc.trim());

      // Logo
      Part logo = req.getPart("logo");
      if (logo != null && logo.getSize() > 0 && isImage(logo)) {
        String url = uploadToCloudinary(logo);
        shop.setLogoUrl(url); // Không xoá ảnh cũ trên Cloudinary
      }

      // Cover
      Part cover = req.getPart("cover");
      if (cover != null && cover.getSize() > 0 && isImage(cover)) {
        String url = uploadToCloudinary(cover);
        shop.setCoverUrl(url); // Yêu cầu đã thêm field coverUrl trong Shop
      }

      tx.begin();
      em.merge(shop);
      tx.commit();

      resp.sendRedirect(req.getContextPath() + "/vendor/shop");
    } catch (NoResultException e) {
      if (tx.isActive()) tx.rollback();
      resp.sendRedirect(req.getContextPath() + "/vendor/shop/create");
    } catch (Exception e) {
      if (tx.isActive()) tx.rollback();
      throw new ServletException(e);
    } finally {
      em.close();
    }
  }

  // --- helpers ---
  private boolean isImage(Part part) {
    String ct = part.getContentType();
    return ct != null && ct.startsWith("image/");
  }

  private String uploadToCloudinary(Part part) throws IOException {
    Cloudinary cloud = CloudinaryConfig.getCloudinary();
    try (InputStream is = part.getInputStream()) {
      byte[] data = is.readAllBytes();
      Map<?, ?> res = cloud.uploader().upload(
          data,
          ObjectUtils.asMap(
              "folder", "shoes-shop/products",   // giữ nguyên folder bạn đang dùng
              "resource_type", "image",
              "use_filename", true,
              "unique_filename", true
          )
      );
      return String.valueOf(res.get("secure_url"));
    }
  }
}
