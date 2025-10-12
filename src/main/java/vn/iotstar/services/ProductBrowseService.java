package vn.iotstar.services;

import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.Category;
import vn.iotstar.entities.ProductImage;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.*;
	
public class ProductBrowseService {

    // ==== DTOs (POJO có getter, tránh lỗi JSP EL) ====
    public static class ItemVM {
        private final Long id;
        private final String name;
        private final String categoryName;
        private final BigDecimal price;
        private final BigDecimal discountPrice;
        private final Double ratingAvg;
        private final String coverUrl;
        public ItemVM(Long id, String name, String categoryName,
                      BigDecimal price, BigDecimal discountPrice,
                      Double ratingAvg, String coverUrl) {
            this.id = id; this.name = name; this.categoryName = categoryName;
            this.price = price; this.discountPrice = discountPrice;
            this.ratingAvg = ratingAvg; this.coverUrl = coverUrl;
        }
        public Long getId() { return id; }
        public String getName() { return name; }
        public String getCategoryName() { return categoryName; }
        public BigDecimal getPrice() { return price; }
        public BigDecimal getDiscountPrice() { return discountPrice; }
        public Double getRatingAvg() { return ratingAvg; }
        public String getCoverUrl() { return coverUrl; }
    }

    public static class PageResult<T> {
        private final List<T> items;
        private final int number;
        private final int size;
        private final long totalItems;
        private final int totalPages;
        public PageResult(List<T> items, int number, int size, long totalItems, int totalPages) {
            this.items = items; this.number = number; this.size = size;
            this.totalItems = totalItems; this.totalPages = totalPages;
        }
        public List<T> getItems() { return items; }
        public int getNumber() { return number; }
        public int getSize() { return size; }
        public long getTotalItems() { return totalItems; }
        public int getTotalPages() { return totalPages; }
        public boolean isHasPrev() { return number > 1; }
        public boolean isHasNext() { return number < totalPages; }
    }

    // ==== API trang danh sách ====
    public PageResult<ItemVM> page(
            String q, Long catId,
            BigDecimal minPrice, BigDecimal maxPrice,
            Integer minRating,
            String sort, int page, int size
    ){
        EntityManager em = JPAConfig.getEntityManager();
        try{
            StringBuilder where = new StringBuilder(" WHERE 1=1 ");
            Map<String,Object> p = new HashMap<>();

            if (q != null && !q.isBlank()) {
                where.append(" AND (LOWER(p.productName) LIKE :kw OR LOWER(p.description) LIKE :kw) ");
                p.put("kw", "%"+q.toLowerCase()+"%");
            }
            if (catId != null) {
                where.append(" AND c.categoryId = :catId ");
                p.put("catId", catId);
            }
            if (minPrice != null) { where.append(" AND p.price >= :minP "); p.put("minP", minPrice); }
            if (maxPrice != null) { where.append(" AND p.price <= :maxP "); p.put("maxP", maxPrice); }
            if (minRating != null) {
                where.append(" AND (p.ratingAvg IS NOT NULL AND p.ratingAvg >= :minR) ");
                p.put("minR", minRating.doubleValue());
            }
            // ⛔️ BỎ lọc status để tránh lỗi enum FQCN (giữ tối thiểu, không đụng entity)
            // where.append(" AND (p.status IS NULL OR p.status = vn.iotstar.Entities.Product$ProductStatus.ACTIVE) ");

            String order = switch (sort == null ? "" : sort) {
                case "price_asc"   -> " ORDER BY p.price ASC ";
                case "price_desc"  -> " ORDER BY p.price DESC ";
                case "rating_desc" -> " ORDER BY p.ratingAvg DESC NULLS LAST ";
                case "new_desc"    -> " ORDER BY p.createdAt DESC ";
                default            -> " ORDER BY p.createdAt DESC ";
            };

            // Count
            TypedQuery<Long> cq = em.createQuery(
                    "SELECT COUNT(p) FROM Product p JOIN p.category c" + where, Long.class);
            p.forEach(cq::setParameter);
            long total = cq.getSingleResult();
            int totalPages = Math.max(1, (int)Math.ceil(total/(double)size));

            // Page items
            TypedQuery<Product> qlist = em.createQuery(
                    "SELECT p FROM Product p JOIN p.category c" + where + order, Product.class);
            p.forEach(qlist::setParameter);
            qlist.setFirstResult((page-1)*size).setMaxResults(size);
            List<Product> products = qlist.getResultList();

            // Cover image (ưu tiên isThumbnail=true)
            TypedQuery<String> coverQ = em.createQuery(
                    "SELECT pi.imageUrl FROM ProductImage pi WHERE pi.product = :prod " +
                    "ORDER BY CASE WHEN pi.isThumbnail = true THEN 0 ELSE 1 END, pi.id", String.class);

            List<ItemVM> items = new ArrayList<>();
            for (Product pr : products) {
                String cover = coverQ.setParameter("prod", pr)
                                     .setMaxResults(1)
                                     .getResultStream().findFirst().orElse(null);
                items.add(new ItemVM(
                    pr.getProductId(),
                    pr.getProductName(),
                    pr.getCategory() != null ? pr.getCategory().getCategoryName() : null,
                    pr.getPrice(),
                    pr.getDiscountPrice(),
                    pr.getRatingAvg() != null ? pr.getRatingAvg().doubleValue() : null,
                    cover
                ));
            }
            return new PageResult<>(items, page, size, total, totalPages);
        } finally { em.close(); }
    }

    public List<Category> categories() {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM Category c ORDER BY c.categoryName", Category.class)
                     .getResultList();
        } finally { em.close(); }
    }

    // ==== API trang chi tiết ====
    public Product findById(Long id) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            // Nạp sẵn category để JSP không bị LazyInitializationException
            TypedQuery<Product> q = em.createQuery(
                "SELECT p FROM Product p LEFT JOIN FETCH p.category WHERE p.productId = :id",
                Product.class
            );
            q.setParameter("id", id);
            List<Product> list = q.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    public List<String> imagesOf(Product p) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT pi.imageUrl FROM ProductImage pi WHERE pi.product = :p " +
                    "ORDER BY CASE WHEN pi.isThumbnail = true THEN 0 ELSE 1 END, pi.id", String.class)
                    .setParameter("p", p)
                    .getResultList();
        } finally { em.close(); }
    }
}
