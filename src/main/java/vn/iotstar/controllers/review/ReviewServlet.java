package vn.iotstar.controllers.review;

import vn.iotstar.services.ReviewService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * ReviewServlet
 *  - POST /review/save
 *  - POST /review/delete
 *
 * Yêu cầu đăng nhập. Hỗ trợ JSON (AJAX) và redirect.
 */
@WebServlet(name = "ReviewServlet", urlPatterns = {"/review/*"})
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo(); // "/save" hoặc "/delete"
        if (path == null) path = "";
        switch (path) {
            case "/save":
                handleSave(req, resp);
                break;
            case "/delete":
                handleDelete(req, resp);
                break;
            default:
                sendError(req, resp, HttpServletResponse.SC_NOT_FOUND, "Unknown action: " + path, null);
        }
    }

    /* ================== /review/save ================== */
    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Long userId = extractUserIdFromSession(session);
        String ctx = req.getContextPath();

        if (userId == null) {
            if (wantsJson(req)) json(resp, 401, "{\"ok\":false,\"error\":\"unauthenticated\"}");
            else resp.sendRedirect(ctx + "/login");
            return;
        }

        Long productId = parseLongObj(req.getParameter("productId"));
        Integer rating = parseIntObj(req.getParameter("rating"));
        String comment  = safe(req.getParameter("comment"));
        String imageUrl = trimToNull(req.getParameter("imageUrl"));
        String videoUrl = trimToNull(req.getParameter("videoUrl"));

        if (productId == null) {
            sendError(req, resp, 400, "productId is required", null);
            return;
        }
        if (rating == null || rating < 1 || rating > 5) {
            // rating invalid
            if (wantsJson(req)) json(resp, 400, "{\"ok\":false,\"error\":\"invalid_rating\"}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv=invalid_rating");
            return;
        }
        if (comment != null && comment.length() > 2000) {
            comment = comment.substring(0, 2000);
        }

        // Kiểm tra quyền review theo DB (đã mua hàng?)
        boolean can = false;
        try {
            can = new ReviewService().canReview(productId, userId);
        } catch (Exception ignore) { can = true; } // fallback: cho phép nếu service có vấn đề

        if (!can) {
            if (wantsJson(req)) json(resp, 403, "{\"ok\":false,\"error\":\"forbidden\"}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv=forbidden");
            return;
        }

        try {
            new ReviewService().saveOrUpdate(userId, productId, rating, comment, imageUrl, videoUrl);
            if (wantsJson(req)) json(resp, 200, "{\"ok\":true}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv=ok");
        } catch (Exception e) {
            e.printStackTrace();
            if (wantsJson(req)) json(resp, 500, "{\"ok\":false,\"error\":\"server_error\"}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv=err");
        }
    }

    /* ================== /review/delete ================== */
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Long userId = extractUserIdFromSession(session);
        String ctx = req.getContextPath();

        if (userId == null) {
            if (wantsJson(req)) json(resp, 401, "{\"ok\":false,\"error\":\"unauthenticated\"}");
            else resp.sendRedirect(ctx + "/login");
            return;
        }

        Long productId = parseLongObj(req.getParameter("productId"));
        if (productId == null) {
            sendError(req, resp, 400, "productId is required", null);
            return;
        }

        try {
            new ReviewService().deleteByUser(userId, productId);
            if (wantsJson(req)) json(resp, 200, "{\"ok\":true}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv_del=ok");
        } catch (Exception e) {
            e.printStackTrace();
            if (wantsJson(req)) json(resp, 500, "{\"ok\":false,\"error\":\"server_error\"}");
            else resp.sendRedirect(ctx + "/product/" + productId + "?rv_del=err");
        }
    }

    /* ================== Helpers ================== */

    private static boolean wantsJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String xhr    = req.getHeader("X-Requested-With");
        return (accept != null && accept.toLowerCase().contains("application/json"))
                || (xhr != null && "xmlhttprequest".equalsIgnoreCase(xhr));
    }

    private static void json(HttpServletResponse resp, int status, String body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.write(body);
        }
    }

    private void sendError(HttpServletRequest req, HttpServletResponse resp,
                           int status, String message, Long productId) throws IOException {
        if (wantsJson(req)) {
            json(resp, status, "{\"ok\":false,\"error\":\"" + esc(message) + "\"}");
        } else {
            if (productId != null) resp.sendRedirect(req.getContextPath() + "/product/" + productId + "?rv=err");
            else resp.sendError(status, message);
        }
    }

    private static Long parseLongObj(String s) {
        try { return (s == null || s.isBlank()) ? null : Long.valueOf(s); }
        catch (Exception e) { return null; }
    }
    private static Integer parseIntObj(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s); }
        catch (Exception e) { return null; }
    }
    private static String safe(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
    private static String trimToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    /* ==== session helpers (tương tự các servlet khác) ==== */
    private static Long extractUserIdFromSession(HttpSession session) {
        if (session == null) return null;

        Object direct = safeGet(session, "userId");
        Long id = castToLong(direct);
        if (id != null) return id;

        String[] keys = new String[]{"currentUser","loginUser","user","account","customer","authUser"};
        for (String k : keys) {
            Object v = safeGet(session, k);
            id = reflectId(v);
            if (id != null) return id;
        }
        return null;
    }
    private static Object safeGet(HttpSession s, String key){
        try { return s.getAttribute(key); } catch (Exception e){ return null; }
    }
    private static Long castToLong(Object v){
        try {
            if (v instanceof Long) return (Long) v;
            if (v instanceof Integer) return ((Integer) v).longValue();
        } catch (Exception ignore){}
        return null;
    }
    private static Long reflectId(Object obj){
        if (obj == null) return null;
        try {
            var m = obj.getClass().getMethod("getUserId");
            Object r = m.invoke(obj);
            Long id = castToLong(r);
            if (id != null) return id;
        } catch (NoSuchMethodException ignore) {
            try {
                var m2 = obj.getClass().getMethod("getId");
                Object r2 = m2.invoke(obj);
                Long id2 = castToLong(r2);
                if (id2 != null) return id2;
            } catch (Exception ignore2) {}
        } catch (Exception ignore) {}
        return null;
    }
    private static String esc(String s){
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"");
    }
}
