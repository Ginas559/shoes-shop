package vn.iotstar.controllers.order;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.*;

/**
 * Quản lý giỏ hàng trong DB.
 *
 * URL Mapping (đã khai báo trong web.xml):
 *  GET  /cart              → hiển thị giỏ hàng
 *  POST /cart/add          → thêm sản phẩm
 *  POST /cart/update       → cập nhật số lượng
 *  POST /cart/delete       → xoá sản phẩm
 */
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /** Lấy userId tạm từ session (mock) */
    private Long resolveUserId(HttpSession session) {
        Object val = session.getAttribute("userId");
        if (val instanceof Long) return (Long) val;
        if (val instanceof Integer) return ((Integer) val).longValue();
        Long demo = 1L;
        session.setAttribute("userId", demo);
        return demo;
    }

    // -------------------- GET --------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Long userId = resolveUserId(session);
        EntityManager em = JPAConfig.getEntityManager();

        try {
            TypedQuery<Cart> q = em.createQuery(
                "SELECT c FROM Cart c LEFT JOIN FETCH c.cartItems ci LEFT JOIN FETCH ci.product WHERE c.user.id = :uid",
                Cart.class);
            q.setParameter("uid", userId);
            List<Cart> carts = q.getResultList();
            Cart cart = carts.isEmpty() ? null : carts.get(0);

            req.setAttribute("cart", cart);
        } catch (Exception e) {
            req.setAttribute("error", "Không tải được giỏ hàng: " + e.getMessage());
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/WEB-INF/views/cart/cart.jsp").forward(req, resp);
    }

    // -------------------- POST --------------------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();
        if (path == null) path = "";

        HttpSession session = req.getSession();
        Long userId = resolveUserId(session);

        switch (path.toLowerCase(Locale.ROOT)) {
            case "/add" -> add(req, resp, userId);
            case "/update" -> update(req, resp, userId);
            case "/delete" -> delete(req, resp, userId);
            default -> resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }

    // -------------------- Helpers --------------------

    /** Thêm sản phẩm vào giỏ */
    private void add(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws IOException {
        HttpSession session = req.getSession(); // ✅ thêm dòng này
        String productIdStr = req.getParameter("productId");
        String qtyStr = req.getParameter("quantity");
        int quantity = (qtyStr == null || qtyStr.isBlank()) ? 1 : Integer.parseInt(qtyStr);

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();

            // Lấy giỏ của user, nếu chưa có thì tạo
            TypedQuery<Cart> q = em.createQuery(
                "SELECT c FROM Cart c WHERE c.user.id = :uid", Cart.class);
            q.setParameter("uid", userId);
            List<Cart> carts = q.getResultList();
            Cart cart = carts.isEmpty() ? null : carts.get(0);
            if (cart == null) {
                cart = new Cart();
                cart.setUser(em.getReference(User.class, userId));
                em.persist(cart);
            }

            Long productId = Long.valueOf(productIdStr);
            Product product = em.getReference(Product.class, productId);

            // Kiểm tra có sẵn item chưa
            TypedQuery<CartItem> qi = em.createQuery(
                "SELECT ci FROM CartItem ci WHERE ci.cart.cartId = :cid AND ci.product.productId = :pid",
                CartItem.class);
            qi.setParameter("cid", cart.getCartId());
            qi.setParameter("pid", productId);
            List<CartItem> found = qi.getResultList();

            if (!found.isEmpty()) {
                CartItem item = found.get(0);
                item.setQuantity(item.getQuantity() + quantity);
                em.merge(item);
            } else {
                CartItem item = new CartItem();
                item.setCart(cart);
                item.setProduct(product);
                item.setQuantity(quantity);
                em.persist(item);
            }

            tx.commit();
            session.setAttribute("flash", "Đã thêm sản phẩm vào giỏ hàng!");
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            session.setAttribute("flash_error", "Lỗi thêm sản phẩm: " + e.getMessage());
        } finally {
            em.close();
        }

        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    /** Cập nhật số lượng */
    private void update(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws IOException {
        HttpSession session = req.getSession(); // ✅ thêm dòng này
        String itemIdStr = req.getParameter("itemId");
        String qtyStr = req.getParameter("quantity");

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();
            CartItem item = em.find(CartItem.class, Long.valueOf(itemIdStr));
            if (item != null && item.getCart().getUser().getId().equals(userId)) {
                int newQty = Math.max(1, Integer.parseInt(qtyStr));
                item.setQuantity(newQty);
                em.merge(item);
            }
            tx.commit();
            session.setAttribute("flash", "Đã cập nhật số lượng.");
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            session.setAttribute("flash_error", "Không thể cập nhật: " + e.getMessage());
        } finally {
            em.close();
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    /** Xoá sản phẩm khỏi giỏ */
    private void delete(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws IOException {
        HttpSession session = req.getSession(); // ✅ thêm dòng này
        String itemIdStr = req.getParameter("itemId");

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();
            CartItem item = em.find(CartItem.class, Long.valueOf(itemIdStr));
            if (item != null && item.getCart().getUser().getId().equals(userId)) {
                em.remove(item);
            }
            tx.commit();
            session.setAttribute("flash", "Đã xoá sản phẩm khỏi giỏ hàng.");
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            session.setAttribute("flash_error", "Không xoá được: " + e.getMessage());
        } finally {
            em.close();
        }

        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}
