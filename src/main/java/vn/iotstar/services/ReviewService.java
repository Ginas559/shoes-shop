package vn.iotstar.services;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Persistence;
import jakarta.persistence.Query;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * ReviewService
 * - Bám sát bảng Product_Review(review_id, rating, comment_text, image_url, video_url, order_item_id, user_id, product_id?, created_at)
 * - Không phụ thuộc entity: dùng native SQL
 * - Cung cấp API:
 *   + stats(productId) -> Stats{avg,count}
 *   + list(productId, limit) -> List<ReviewItem>
 *   + findByUser(productId, userId) -> ReviewItem | null
 *   + canReview(productId, userId) -> boolean (đã mua hàng)
 *   + saveOrUpdate(userId, productId, rating, comment, imageUrl, videoUrl)
 *   + deleteByUser(userId, productId)
 *
 * Ghi chú:
 * - canReview: kiểm tra tồn tại đơn hàng của user có chứa product (JOIN Order_Item + [Order])
 * - Sau save/delete: cập nhật Product.rating_avg = AVG(rating) từ Product_Review
 */
public class ReviewService {

    private static volatile EntityManagerFactory EMF;

    private static EntityManagerFactory emf() {
        if (EMF == null) {
            synchronized (ReviewService.class) {
                if (EMF == null) {
                    EMF = Persistence.createEntityManagerFactory("dataSource");
                }
            }
        }
        return EMF;
    }

    private EntityManager em() {
        return emf().createEntityManager();
    }

    /* ============================ DTOs ============================ */

    /** Tổng hợp cho JSP: reviewStats.avg / reviewStats.count */
    public static class Stats {
        private final double avg;
        private final long count;
        public Stats(double avg, long count) { this.avg = avg; this.count = count; }
        public double getAvg()   { return avg; }
        public long   getCount() { return count; }
    }

    /** Item hiển thị review */
    public static class ReviewItem {
        private final String userName;
        private final LocalDateTime createdAt;
        private final int rating;
        private final String commentText;
        private final String imageUrl;
        private final String videoUrl;

        public ReviewItem(String userName, LocalDateTime createdAt, int rating,
                          String commentText, String imageUrl, String videoUrl) {
            this.userName   = userName == null ? "" : userName;
            this.createdAt  = createdAt;
            this.rating     = rating;
            this.commentText= commentText == null ? "" : commentText;
            this.imageUrl   = imageUrl;
            this.videoUrl   = videoUrl;
        }
        public String getUserName()     { return userName; }
        public LocalDateTime getCreatedAt(){ return createdAt; }
        public int getRating()          { return rating; }
        public String getCommentText()  { return commentText; }
        public String getImageUrl()     { return imageUrl; }
        public String getVideoUrl()     { return videoUrl; }
    }

    /* ============================ READ ============================ */

    /** Thống kê trung bình & số lượng review của 1 sản phẩm */
    public Stats stats(Long productId) {
        EntityManager em = em();
        try {
            // AVG float để ra double, COUNT bigint
            String sql = "SELECT " +
                    "  COALESCE(AVG(CAST(r.rating AS FLOAT)), 0.0) AS avg_rating, " +
                    "  COUNT(*) AS cnt " +
                    "FROM Product_Review r " +
                    "WHERE r.product_id = :pid";
            Object[] row = (Object[]) em.createNativeQuery(sql)
                    .setParameter("pid", productId)
                    .getSingleResult();
            double avg = row[0] == null ? 0.0 : ((Number) row[0]).doubleValue();
            long cnt   = row[1] == null ? 0L  : ((Number) row[1]).longValue();
            return new Stats(roundHalfUp(avg, 1), cnt);
        } finally {
            em.close();
        }
    }

    /** Danh sách review mới nhất (kèm user name) */
    @SuppressWarnings("unchecked")
    public List<ReviewItem> list(Long productId, Integer limit) {
        int lim = (limit == null || limit <= 0) ? 10 : limit;
        EntityManager em = em();
        try {
            // Lấy tên người dùng linh hoạt: full_name/username/email, fallback "User#id"
            String sql =
                "SELECT " +
                "  COALESCE(u.full_name, u.username, u.email, CONCAT('User#', CAST(u.user_id AS VARCHAR(20)))) AS user_name, " +
                "  r.created_at, r.rating, r.comment_text, r.image_url, r.video_url " +
                "FROM Product_Review r " +
                "JOIN [User] u ON u.user_id = r.user_id " +
                "WHERE r.product_id = :pid " +
                "ORDER BY r.created_at DESC";

            Query q = em.createNativeQuery(sql);
            q.setParameter("pid", productId);
            q.setMaxResults(lim);

            List<Object[]> rows = q.getResultList();
            List<ReviewItem> out = new ArrayList<>(rows.size());
            for (Object[] r : rows) {
                String userName   = toStr(r[0]);
                LocalDateTime ts  = toLdt(r[1]);
                int rating        = toInt(r[2]);
                String cmt        = toStr(r[3]);
                String img        = toStr(r[4]);
                String vid        = toStr(r[5]);
                out.add(new ReviewItem(userName, ts, rating, cmt, img, vid));
            }
            return out;
        } finally {
            em.close();
        }
    }

    /** Review của chính user cho 1 sản phẩm (để form hiển thị lại) */
    public ReviewItem findByUser(Long productId, Long userId) {
        if (userId == null) return null;
        EntityManager em = em();
        try {
            String sql =
                "SELECT " +
                "  COALESCE(u.full_name, u.username, u.email, CONCAT('User#', CAST(u.user_id AS VARCHAR(20)))) AS user_name, " +
                "  r.created_at, r.rating, r.comment_text, r.image_url, r.video_url " +
                "FROM Product_Review r " +
                "JOIN [User] u ON u.user_id = r.user_id " +
                "WHERE r.product_id = :pid AND r.user_id = :uid";
            List<?> rows = em.createNativeQuery(sql)
                    .setParameter("pid", productId)
                    .setParameter("uid", userId)
                    .getResultList();
            if (rows.isEmpty()) return null;
            Object[] r = (Object[]) rows.get(0);
            return new ReviewItem(
                    toStr(r[0]),
                    toLdt(r[1]),
                    toInt(r[2]),
                    toStr(r[3]),
                    toStr(r[4]),
                    toStr(r[5])
            );
        } finally {
            em.close();
        }
    }

    /**
     * User có được phép review?
     * Mặc định: phải đăng nhập & từng mua sản phẩm (tồn tại Order_Item của user cho product).
     * Nếu muốn “ai cũng review được”, có thể sửa return true nếu userId != null.
     */
    public boolean canReview(Long productId, Long userId) {
        if (userId == null) return false;
        EntityManager em = em();
        try {
            // Tuỳ tên bảng Order: dùng [Order] để an toàn với từ khoá
            String sql =
                "SELECT COUNT(*) " +
                "FROM Order_Item oi " +
                "JOIN [Order] o ON o.order_id = oi.order_id " +
                "WHERE o.user_id = :uid AND oi.product_id = :pid";
            Number n = (Number) em.createNativeQuery(sql)
                    .setParameter("uid", userId)
                    .setParameter("pid", productId)
                    .getSingleResult();
            return n != null && n.longValue() > 0;
        } catch (Exception e) {
            // Nếu schema khác (VD: bảng Orders), fallback: cho review nếu đã đăng nhập
            return true;
        } finally {
            em.close();
        }
    }

    /* ============================ WRITE ============================ */

    /** Tạo hoặc cập nhật review của user cho 1 product */
    public void saveOrUpdate(Long userId, Long productId, int rating,
                             String comment, String imageUrl, String videoUrl) {
        EntityManager em = em();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            // Đã có review?
            String sel = "SELECT review_id FROM Product_Review WHERE product_id = :pid AND user_id = :uid";
            List<?> ids = em.createNativeQuery(sel)
                    .setParameter("pid", productId)
                    .setParameter("uid", userId)
                    .getResultList();

            LocalDateTime now = LocalDateTime.now();

            if (ids != null && !ids.isEmpty()) {
                // UPDATE
                String upd =
                    "UPDATE Product_Review " +
                    "SET rating = :rating, comment_text = :comment, image_url = :img, video_url = :vid, created_at = :ts " +
                    "WHERE product_id = :pid AND user_id = :uid";
                em.createNativeQuery(upd)
                        .setParameter("rating", rating)
                        .setParameter("comment", safe(comment))
                        .setParameter("img", safe(imageUrl))
                        .setParameter("vid", safe(videoUrl))
                        .setParameter("ts", Timestamp.valueOf(now))
                        .setParameter("pid", productId)
                        .setParameter("uid", userId)
                        .executeUpdate();
            } else {
                // INSERT (order_item_id để null nếu bạn không truyền)
                String ins =
                    "INSERT INTO Product_Review (product_id, user_id, rating, comment_text, image_url, video_url, created_at) " +
                    "VALUES (:pid, :uid, :rating, :comment, :img, :vid, :ts)";
                em.createNativeQuery(ins)
                        .setParameter("pid", productId)
                        .setParameter("uid", userId)
                        .setParameter("rating", rating)
                        .setParameter("comment", safe(comment))
                        .setParameter("img", safe(imageUrl))
                        .setParameter("vid", safe(videoUrl))
                        .setParameter("ts", Timestamp.valueOf(now))
                        .executeUpdate();
            }

            // Cập nhật Product.rating_avg
            updateProductAverage(em, productId);

            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Xoá review của user cho product */
    public void deleteByUser(Long userId, Long productId) {
        EntityManager em = em();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            String del = "DELETE FROM Product_Review WHERE product_id = :pid AND user_id = :uid";
            em.createNativeQuery(del)
                    .setParameter("pid", productId)
                    .setParameter("uid", userId)
                    .executeUpdate();

            // cập nhật lại average
            updateProductAverage(em, productId);

            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /* ============================ Helpers ============================ */

    private void updateProductAverage(EntityManager em, Long productId) {
        String upd =
            "UPDATE Product " +
            "SET rating_avg = (SELECT COALESCE(AVG(CAST(r.rating AS FLOAT)), 0.0) FROM Product_Review r WHERE r.product_id = :pid) " +
            "WHERE product_id = :pid";
        em.createNativeQuery(upd)
                .setParameter("pid", productId)
                .executeUpdate();
    }

    private static String safe(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
    private static String toStr(Object o) {
        return (o == null) ? "" : o.toString();
    }
    private static int toInt(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return ((Number)o).intValue();
        try { return Integer.parseInt(String.valueOf(o)); } catch (Exception e){ return 0; }
    }
    private static LocalDateTime toLdt(Object ts) {
        if (ts == null) return null;
        if (ts instanceof Timestamp) return ((Timestamp) ts).toLocalDateTime();
        try {
            return Timestamp.valueOf(String.valueOf(ts)).toLocalDateTime();
        } catch (Exception e) {
            return null;
        }
    }
    
    /** Làm tròn half-up (chuẩn) đến số chữ số thập phân nhất định */
    private static double roundHalfUp(double value, int scale) {
        if (Double.isNaN(value)) return 0.0;
        double pow = Math.pow(10, scale);
        return Math.round(value * pow) / pow;
    }
    
    
}
