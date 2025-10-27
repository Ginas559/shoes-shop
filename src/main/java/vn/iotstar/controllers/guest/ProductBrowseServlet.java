package vn.iotstar.controllers.guest;

import vn.iotstar.services.ProductBrowseService;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.Category;

// + thêm import
import vn.iotstar.services.FavoriteService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.ArrayList;
// reflection để không phụ thuộc compile-time vào ViewedService
import java.lang.reflect.Method;
import java.util.Enumeration;

/**
 * Lưu ý cập nhật:
 * - Bổ sung nạp dữ liệu Review/Comment bằng reflection:
 *   + reviewStats  {avg(double), count(long)}
 *   + reviews      List<...>  (cần các field JSP dùng: userName, createdAt, rating, commentText, imageUrl, videoUrl)
 *   + userReview   1 review của chính user (nếu có)
 *   + canReview    boolean
 *   + comments     List<...>  (cần: userName, createdAt, content)
 * - Nếu thiếu service tương ứng -> đặt mặc định an toàn, không làm vỡ trang.
 */
public class ProductBrowseServlet extends HttpServlet {
    private final ProductBrowseService svc = new ProductBrowseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sp = req.getServletPath(); // "/products" hoặc "/product"
        if ("/products".equals(sp)) list(req, resp);
        else detail(req, resp);
    }

    private void list(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), 20);

        Long shopId = parseLongObj(req.getParameter("shopId"));

        var result = svc.page(
                req.getParameter("q"),
                parseLongObj(req.getParameter("catId")),
                parseBD(req.getParameter("minPrice")),
                parseBD(req.getParameter("maxPrice")),
                parseIntObj(req.getParameter("minRating")),
                shopId,
                req.getParameter("sort"),
                page, size
        );

        String shopQ = req.getParameter("shopQ");
        var shops = svc.shops(shopQ);
        List<Category> cats = svc.categories();

        req.setAttribute("pageTitle", "Sản phẩm");
        req.setAttribute("page", result);
        req.setAttribute("categories", cats);
        req.setAttribute("shopId", shopId);
        req.setAttribute("shops", shops);
        req.setAttribute("shopQ", shopQ);

        req.getRequestDispatcher("/WEB-INF/views/products/list.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo(); // "/{id}"
        Long id = (path == null || path.length() < 2) ? null : parseLongObj(path.substring(1));
        if (id == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Product p = svc.findById(id);
        if (p == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // ====== [VIEWED HOOK + LOG] ======
        try {
            Long userId = extractUserIdFromSession(req.getSession(false));
            if (userId != null) {
                System.out.println("[Viewed] userId=" + userId + " -> productId=" + p.getProductId());
                Class<?> clazz = Class.forName("vn.iotstar.services.ViewedService");
                Object viewedSvc = clazz.getDeclaredConstructor().newInstance();

                // touch(userId, productId)
                Method touch = clazz.getMethod("touch", Long.class, Long.class);
                touch.invoke(viewedSvc, userId, p.getProductId());
                System.out.println("[Viewed] touch() done");

                // recentByUser(userId, limit) -> List<Product>
                Method recentByUser = clazz.getMethod("recentByUser", Long.class, Integer.class);
                @SuppressWarnings("unchecked")
                // lấy đúng 6, và KHÔNG loại sản phẩm hiện tại để hiển thị đủ 6
                List<Product> recent = (List<Product>) recentByUser.invoke(viewedSvc, userId, Integer.valueOf(6));

                if (recent != null && !recent.isEmpty()) {
                    // Convert -> VM có đủ field JSP cần
                    List<RecentViewVM> vms = new ArrayList<>(recent.size());
                    for (Product pr : recent) {
                        if (pr == null) continue;
                        String thumb = resolveThumbnailUrl(pr);
                        vms.add(new RecentViewVM(
                                pr.getProductId(),
                                pr.getProductName(),
                                thumb,
                                pr.getPrice(),
                                pr.getDiscountPrice()
                        ));
                    }
                    req.setAttribute("recentViewed", vms);
                    req.setAttribute("viewedDebug", "OK — recent=" + vms.size());
                    System.out.println("[Viewed] recentByUser size=" + vms.size());
                } else {
                    req.setAttribute("viewedDebug", "OK — recent=0");
                    System.out.println("[Viewed] recentByUser empty");
                }

                // ====== [FAVORITE HOOK] ======
                try {
                    FavoriteService favSvc = new FavoriteService();
                    boolean isFav = favSvc.isFav(userId, p.getProductId());
                    long favCount = favSvc.countByProduct(p.getProductId());
                    req.setAttribute("isFav", isFav);
                    req.setAttribute("favoriteCount", favCount);
                    System.out.println("[Favorite] isFav=" + isFav + " count=" + favCount);
                } catch (Exception e) {
                    System.out.println("[Favorite] ERROR: " + e.getMessage());
                    req.setAttribute("isFav", false);
                    req.setAttribute("favoriteCount", 0L);
                }
                // ====== [END FAVORITE HOOK] ======

                // ====== [REVIEW HOOK - user logged in] ======
                loadReviewsAndComments(req, p.getProductId(), userId);
                // ====== [END REVIEW HOOK] ======

            } else {
                req.setAttribute("viewedDebug", "SKIP — no userId in session");
                System.out.println("[Viewed] SKIP — no userId in session");

                // user chưa đăng nhập vẫn cần count
                try {
                    FavoriteService favSvc = new FavoriteService();
                    long favCount = favSvc.countByProduct(p.getProductId());
                    req.setAttribute("isFav", false);
                    req.setAttribute("favoriteCount", favCount);
                } catch (Exception e) {
                    req.setAttribute("isFav", false);
                    req.setAttribute("favoriteCount", 0L);
                }

                // ====== [REVIEW HOOK - guest] ======
                loadReviewsAndComments(req, p.getProductId(), null);
                // ====== [END REVIEW HOOK] ======
            }
        } catch (ClassNotFoundException e) {
            req.setAttribute("viewedDebug", "SKIP — ViewedService not found");
            System.out.println("[Viewed] SKIP — ViewedService class not found");

            // vẫn nạp review/comment dù thiếu ViewedService
            loadReviewsAndComments(req, p.getProductId(), extractUserIdFromSession(req.getSession(false)));
        } catch (Exception e) {
            req.setAttribute("viewedDebug", "ERROR — " + e.getClass().getSimpleName() + ": " + e.getMessage());
            System.out.println("[Viewed] ERROR — " + e.getMessage());
            log("[ProductBrowseServlet] Viewed hook error: " + e.getMessage());

            // vẫn nạp review/comment nếu có lỗi Viewed
            loadReviewsAndComments(req, p.getProductId(), extractUserIdFromSession(req.getSession(false)));
        }
        // ====== [END VIEWED HOOK + LOG] ======

        req.setAttribute("pageTitle", p.getProductName());
        req.setAttribute("product", p);
        req.setAttribute("images", svc.imagesOf(p));
        req.getRequestDispatcher("/WEB-INF/views/products/detail.jsp").forward(req, resp);
    }

    /** Nạp reviewStats/reviews/userReview/canReview/comments bằng reflection (an toàn khi service chưa sẵn). */
    private void loadReviewsAndComments(HttpServletRequest req, Long productId, Long userId) {
        // ==== Defaults trước để trang luôn chạy ====
        req.setAttribute("reviewStats", new SimpleStats(0.0, 0L));
        req.setAttribute("reviews", new ArrayList<>());
        req.setAttribute("userReview", null);
        req.setAttribute("canReview", Boolean.FALSE);
        req.setAttribute("comments", new ArrayList<>());

        // ---- ReviewService ----
        try {
            Class<?> rCls = Class.forName("vn.iotstar.services.ReviewService");
            Object rSvc = rCls.getDeclaredConstructor().newInstance();

            // stats(productId) -> object có getAvg()/getAverage()/avg và getCount()/getTotal()/count
            try {
                Method mStats = rCls.getMethod("stats", Long.class);
                Object statsObj = mStats.invoke(rSvc, productId);
                double avg = readDouble(statsObj, "getAvg", "getAverage", "avg");
                long cnt   = readLong(statsObj, "getCount", "getTotal", "count");
                req.setAttribute("reviewStats", new SimpleStats(avg, cnt));
            } catch (NoSuchMethodException ns) {
                // fallback: list để tính count (avg = 0 nếu chưa có)
                try {
                    Method mList = rCls.getMethod("list", Long.class, Integer.class);
                    Object list = mList.invoke(rSvc, productId, Integer.valueOf(10));
                    if (list instanceof List) {
                        int c = ((List<?>) list).size();
                        req.setAttribute("reviewStats", new SimpleStats(0.0, c));
                    }
                } catch (Exception ignore) {}
            }

            // reviews(productId, limit)
            try {
                Method mList = rCls.getMethod("list", Long.class, Integer.class);
                @SuppressWarnings("unchecked")
                List<?> rvList = (List<?>) mList.invoke(rSvc, productId, Integer.valueOf(10));
                if (rvList != null) req.setAttribute("reviews", rvList);
            } catch (NoSuchMethodException ns) {
                // có thể service dùng tên khác: findLatest
                try {
                    Method mList2 = rCls.getMethod("findLatest", Long.class, Integer.class);
                    @SuppressWarnings("unchecked")
                    List<?> rvList2 = (List<?>) mList2.invoke(rSvc, productId, Integer.valueOf(10));
                    if (rvList2 != null) req.setAttribute("reviews", rvList2);
                } catch (Exception ignore) {}
            }

            // userReview(productId, userId)
            if (userId != null) {
                try {
                    Method mMy = rCls.getMethod("findByUser", Long.class, Long.class);
                    Object my = mMy.invoke(rSvc, productId, userId);
                    req.setAttribute("userReview", my);
                } catch (Exception ignore) {}
            }

            // canReview(productId, userId)
            try {
                boolean can = false;
                if (userId != null) {
                    try {
                        Method mCan = rCls.getMethod("canReview", Long.class, Long.class);
                        Object r = mCan.invoke(rSvc, productId, userId);
                        can = toBool(r);
                    } catch (NoSuchMethodException miss) {
                        // nếu service không có, default: có login là cho review
                        can = true;
                    }
                }
                req.setAttribute("canReview", can);
            } catch (Exception ignore) {}

        } catch (ClassNotFoundException notFound) {
            System.out.println("[Review] SKIP — ReviewService not found");
            // giữ defaults
        } catch (Exception e) {
            System.out.println("[Review] ERROR — " + e.getMessage());
            // giữ defaults
        }

        // ---- CommentService ----
        try {
            Class<?> cCls = Class.forName("vn.iotstar.services.CommentService");
            Object cSvc = cCls.getDeclaredConstructor().newInstance();

            try {
                Method mList = cCls.getMethod("list", Long.class, Integer.class);
                @SuppressWarnings("unchecked")
                List<?> cmList = (List<?>) mList.invoke(cSvc, productId, Integer.valueOf(10));
                if (cmList != null) req.setAttribute("comments", cmList);
            } catch (NoSuchMethodException ns) {
                try {
                    Method mList2 = cCls.getMethod("findLatest", Long.class, Integer.class);
                    @SuppressWarnings("unchecked")
                    List<?> cmList2 = (List<?>) mList2.invoke(cSvc, productId, Integer.valueOf(10));
                    if (cmList2 != null) req.setAttribute("comments", cmList2);
                } catch (Exception ignore) {}
            }

        } catch (ClassNotFoundException notFound) {
            System.out.println("[Comment] SKIP — CommentService not found");
        } catch (Exception e) {
            System.out.println("[Comment] ERROR — " + e.getMessage());
        }
    }

    /** Nhỏ gọn: model tổng hợp cho reviewStats (JSP: reviewStats.avg / reviewStats.count) */
    public static class SimpleStats {
        private final double avg;
        private final long count;
        public SimpleStats(double avg, long count){ this.avg = avg; this.count = count; }
        public double getAvg(){ return avg; }
        public long getCount(){ return count; }
    }

    /**
     * Lấy URL thumbnail cho 1 Product:
     * - Nếu svc.imagesOf trả List<String>: lấy phần tử đầu
     * - Nếu trả object có getIsThumbnail()/getImageUrl(): ưu tiên isThumbnail, fallback ảnh đầu
     * - Nếu không có ảnh: trả ""
     */
    private String resolveThumbnailUrl(Product pr) {
        try {
            List<?> imgs = svc.imagesOf(pr);
            if (imgs == null || imgs.isEmpty()) return "";

            Object prefer = null;
            for (Object o : imgs) {
                if (o == null) continue;
                if (o instanceof String) { // List<String>
                    prefer = o;
                    break;
                }
                try {
                    Method mIsThumb = o.getClass().getMethod("getIsThumbnail");
                    Object v = mIsThumb.invoke(o);
                    if (v instanceof Boolean && (Boolean) v) {
                        prefer = o;
                        break;
                    }
                } catch (NoSuchMethodException ignore) {
                } catch (Exception ignore) {}
                if (prefer == null) prefer = o;
            }

            String raw;
            if (prefer instanceof String) {
                raw = (String) prefer;
            } else {
                try {
                    Method mUrl = prefer.getClass().getMethod("getImageUrl");
                    Object url = mUrl.invoke(prefer);
                    raw = (url != null) ? url.toString() : "";
                } catch (Exception e) {
                    Object first = imgs.get(0);
                    raw = (first instanceof String) ? (String) first : "";
                }
            }

            if (raw == null) raw = "";
            return raw.replace("/assset/", "/assets/");
        } catch (Exception e) {
            return "";
        }
    }

    // ViewModel nhỏ cho JSP
    public static class RecentViewVM {
        private final Long productId;
        private final String productName;
        private final String coverUrl;
        private final BigDecimal price;
        private final BigDecimal discountPrice;

        public RecentViewVM(Long productId, String productName, String coverUrl,
                            BigDecimal price, BigDecimal discountPrice) {
            this.productId     = productId;
            this.productName   = (productName == null) ? "" : productName;
            this.coverUrl      = (coverUrl   == null) ? "" : coverUrl;
            this.price         = price;
            this.discountPrice = discountPrice;
        }
        public Long getProductId()         { return productId; }
        public String getProductName()     { return productName; }
        public String getCoverUrl()        { return coverUrl; }
        public BigDecimal getPrice()       { return price; }
        public BigDecimal getDiscountPrice(){ return discountPrice; }
    }

    // helpers
    private int parseInt(String s, int d){ try { return Integer.parseInt(s);}catch(Exception e){return d;}}
    private Integer parseIntObj(String s){ try { return (s==null||s.isBlank())?null:Integer.valueOf(s);}catch(Exception e){return null;}}
    private Long parseLongObj(String s){ try { return (s==null||s.isBlank())?null:Long.valueOf(s);}catch(Exception e){return null;}}
    private BigDecimal parseBD(String s){ try { return (s==null||s.isBlank())?null:new BigDecimal(s);}catch(Exception e){return null;}}

    private Long extractUserIdFromSession(HttpSession session){
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

        try {
            Enumeration<String> names = session.getAttributeNames();
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                Object v = session.getAttribute(name);
                id = castToLong(v);
                if (id != null) return id;

                id = reflectId(v);
                if (id != null) return id;
            }
        } catch (Exception ignore) {}
        return null;
    }

    private Object safeGet(HttpSession s, String key){
        try { return s.getAttribute(key); } catch (Exception e){ return null; }
    }
    private Long castToLong(Object v){
        try {
            if (v instanceof Long) return (Long) v;
            if (v instanceof Integer) return ((Integer) v).longValue();
        } catch (Exception ignore){}
        return null;
    }
    private Long reflectId(Object obj){
        if (obj == null) return null;
        try {
            Method m = obj.getClass().getMethod("getUserId");
            Object r = m.invoke(obj);
            Long id = castToLong(r);
            if (id != null) return id;
        } catch (NoSuchMethodException ignore) {
            try {
                Method m2 = obj.getClass().getMethod("getId");
                Object r2 = m2.invoke(obj);
                Long id2 = castToLong(r2);
                if (id2 != null) return id2;
            } catch (Exception ignore2) {}
        } catch (Exception ignore) {}
        return null;
    }

    // tiny reflect helpers
    private static boolean toBool(Object o){
        if (o == null) return false;
        if (o instanceof Boolean) return (Boolean)o;
        if (o instanceof Number) return ((Number)o).intValue()!=0;
        return "true".equalsIgnoreCase(String.valueOf(o));
    }
    private static double readDouble(Object obj, String... getters){
        for (String g : getters){
            try {
                Method m = obj.getClass().getMethod(g);
                Object v = m.invoke(obj);
                if (v instanceof Number) return ((Number)v).doubleValue();
                return Double.parseDouble(String.valueOf(v));
            } catch(Exception ignore){}
        }
        return 0.0;
    }
    private static long readLong(Object obj, String... getters){
        for (String g : getters){
            try {
                Method m = obj.getClass().getMethod(g);
                Object v = m.invoke(obj);
                if (v instanceof Number) return ((Number)v).longValue();
                return Long.parseLong(String.valueOf(v));
            } catch(Exception ignore){}
        }
        return 0L;
    }
}
