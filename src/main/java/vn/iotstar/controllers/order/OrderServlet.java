package vn.iotstar.controllers.order;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Order;
import vn.iotstar.entities.OrderItem;

public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private Long resolveUserId(HttpSession session) {
        Object val = session.getAttribute("userId");
        if (val instanceof Long) return (Long) val;
        if (val instanceof Integer) return ((Integer) val).longValue();
        Long demo = 1L;
        session.setAttribute("userId", demo);
        return demo;
    }

    private int parsePositiveInt(String s, int def) {
        try {
            int v = Integer.parseInt(s);
            return v > 0 ? v : def;
        } catch (Exception e) {
            return def;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Long userId = resolveUserId(session);

        String servletPath = req.getServletPath(); // /orders hoặc /order
        String pathInfo = req.getPathInfo();       // null | /{id}

        if ("/orders".equals(servletPath)) {
            list(req, resp, userId);
            return;
        }

        if ("/order".equals(servletPath) && pathInfo != null && pathInfo.length() > 1) {
            String idStr = pathInfo.substring(1);
            detail(req, resp, userId, idStr);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/orders");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Long userId = resolveUserId(session);

        String servletPath = req.getServletPath();
        String pathInfo = req.getPathInfo();
        String action = req.getParameter("action");

        if ("/order".equals(servletPath) && pathInfo != null && pathInfo.length() > 1) {
            String idStr = pathInfo.substring(1);
            if ("cancel".equalsIgnoreCase(action)) {
                cancel(req, resp, userId, idStr);
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/orders");
    }

    // ------------------ LIST (with pagination) ------------------
    private void list(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {

        String statusParam = req.getParameter("status");
        int page = parsePositiveInt(req.getParameter("page"), 1);
        int size = parsePositiveInt(req.getParameter("size"), 10);
        int offset = (page - 1) * size;

        EntityManager em = JPAConfig.getEntityManager();

        try {
            List<Order> orders;
            long totalItems;

            boolean isAll = (statusParam == null || statusParam.isBlank() || "ALL".equalsIgnoreCase(statusParam));

            if (isAll) {
                // Count
                TypedQuery<Long> cq = em.createQuery(
                        "SELECT COUNT(o) FROM vn.iotstar.entities.Order o WHERE o.user.id = :uid", Long.class);
                cq.setParameter("uid", userId);
                totalItems = cq.getSingleResult();

                // Page data
                TypedQuery<Order> q = em.createQuery(
                        "SELECT o FROM vn.iotstar.entities.Order o WHERE o.user.id = :uid ORDER BY o.createdAt DESC",
                        Order.class);
                q.setParameter("uid", userId);
                q.setFirstResult(offset);
                q.setMaxResults(size);
                orders = q.getResultList();
            } else {
                Order.OrderStatus st;
                try {
                    st = Order.OrderStatus.valueOf(statusParam.toUpperCase(Locale.ROOT));
                } catch (Exception e) {
                    st = Order.OrderStatus.NEW;
                }

                // Count
                TypedQuery<Long> cq = em.createQuery(
                        "SELECT COUNT(o) FROM vn.iotstar.entities.Order o WHERE o.user.id = :uid AND o.status = :st",
                        Long.class);
                cq.setParameter("uid", userId);
                cq.setParameter("st", st);
                totalItems = cq.getSingleResult();

                // Page data
                TypedQuery<Order> q = em.createQuery(
                        "SELECT o FROM vn.iotstar.entities.Order o " +
                        "WHERE o.user.id = :uid AND o.status = :st ORDER BY o.createdAt DESC",
                        Order.class);
                q.setParameter("uid", userId);
                q.setParameter("st", st);
                q.setFirstResult(offset);
                q.setMaxResults(size);
                orders = q.getResultList();
            }

            long totalPages = (totalItems + size - 1) / size;

            req.setAttribute("orders", orders);
            req.setAttribute("status", isAll ? "ALL" : statusParam.toUpperCase(Locale.ROOT));
            req.setAttribute("page", page);
            req.setAttribute("size", size);
            req.setAttribute("totalItems", totalItems);
            req.setAttribute("totalPages", totalPages);
        } catch (Exception e) {
            req.setAttribute("error", "Không tải được danh sách đơn hàng: " + e.getMessage());
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/WEB-INF/views/order/order_list.jsp").forward(req, resp);
    }

    // ------------------ DETAIL (JOIN FETCH để tránh LazyInitialization) ------------------
    private void detail(HttpServletRequest req, HttpServletResponse resp, Long userId, String idStr)
            throws ServletException, IOException {

        EntityManager em = JPAConfig.getEntityManager();

        try {
            Long oid = Long.valueOf(idStr);

            // Nạp trước các quan hệ cần dùng trong JSP (address, user, shop, shipper)
            TypedQuery<Order> qo = em.createQuery(
                "SELECT o FROM vn.iotstar.entities.Order o " +
                "LEFT JOIN FETCH o.address " +
                "LEFT JOIN FETCH o.user " +
                "LEFT JOIN FETCH o.shop " +
                "LEFT JOIN FETCH o.shipper " +
                "WHERE o.orderId = :oid", Order.class);
            qo.setParameter("oid", oid);

            Order order;
            try {
                order = qo.getSingleResult();
            } catch (NoResultException nre) {
                order = null;
            }

            if (order == null || order.getUser() == null || !order.getUser().getId().equals(userId)) {
                req.setAttribute("error", "Không tìm thấy đơn hàng hoặc bạn không có quyền xem.");
                req.getRequestDispatcher("/WEB-INF/views/order/order_detail.jsp").forward(req, resp);
                return;
            }

            // load items + product
            TypedQuery<OrderItem> qi = em.createQuery(
                "SELECT oi FROM vn.iotstar.entities.OrderItem oi JOIN FETCH oi.product WHERE oi.order.orderId = :oid",
                OrderItem.class);
            qi.setParameter("oid", oid);
            List<OrderItem> items = qi.getResultList();

            req.setAttribute("order", order);
            req.setAttribute("items", items);
        } catch (Exception e) {
            req.setAttribute("error", "Lỗi khi tải chi tiết đơn hàng: " + e.getMessage());
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/WEB-INF/views/order/order_detail.jsp").forward(req, resp);
    }

    // ------------------ CANCEL (POST) ------------------
    private void cancel(HttpServletRequest req, HttpServletResponse resp, Long userId, String idStr)
            throws IOException {

        EntityManager em = JPAConfig.getEntityManager();
        EntityTransaction tx = null;

        String redirectBase = req.getContextPath() + "/order/" + idStr;

        try {
            Long oid = Long.valueOf(idStr);

            // Lấy order để kiểm tra quyền
            Order order = em.find(Order.class, oid);
            if (order == null || order.getUser() == null || !order.getUser().getId().equals(userId)) {
                resp.sendRedirect(redirectBase + "?msg=not_allowed");
                return;
            }

            Order.OrderStatus current = order.getStatus();
            if (current != Order.OrderStatus.NEW && current != Order.OrderStatus.CONFIRMED) {
                resp.sendRedirect(redirectBase + "?msg=cannot_cancel_in_status_" + current.name());
                return;
            }

            tx = em.getTransaction();
            tx.begin();
            order.setStatus(Order.OrderStatus.CANCELED);
            tx.commit();

            resp.sendRedirect(redirectBase + "?msg=cancel_success");
        } catch (Exception ex) {
            if (tx != null && tx.isActive()) tx.rollback();
            resp.sendRedirect(redirectBase + "?msg=cancel_failed");
        } finally {
            em.close();
        }
    }
}
