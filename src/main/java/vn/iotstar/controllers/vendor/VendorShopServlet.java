package vn.iotstar.controllers.vendor;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
import jakarta.persistence.*;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/shop/create"})
public class VendorShopServlet extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.getRequestDispatcher("/WEB-INF/views/vendor/shop-create.jsp").forward(req, resp);
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    Long uid = SessionUtil.currentUserId(req);
    String name = req.getParameter("shopName");
    String desc = req.getParameter("description");

    EntityManager em = JPAConfig.getEntityManager();
    EntityTransaction tx = em.getTransaction();
    try {
      tx.begin();
      Shop s = Shop.builder()
              .shopName(name)
              .description(desc)
              .status(Shop.ShopStatus.ACTIVE)
              .vendor(em.getReference(User.class, uid))
              .build();
      em.persist(s);
      tx.commit();
      resp.sendRedirect(req.getContextPath() + "/vendor/dashboard");
    } catch (Exception e) {
      if (tx.isActive()) tx.rollback();
      throw e;
    } finally { em.close(); }
  }
}
