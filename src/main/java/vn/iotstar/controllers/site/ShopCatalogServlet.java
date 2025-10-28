// src/main/java/vn/iotstar/controllers/site/ShopCatalogServlet.java
package vn.iotstar.controllers.site;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

import vn.iotstar.entities.Product;
import vn.iotstar.entities.Shop;
import vn.iotstar.services.ProductService;
import vn.iotstar.services.ShopService;

@WebServlet(urlPatterns = {"/vendor/*", "/vendor"})
public class ShopCatalogServlet extends HttpServlet {

    private ShopService shopService;
    private ProductService productService;

    @Override
    public void init() throws ServletException {
        this.shopService = new ShopService();
        this.productService = new ProductService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- Resolve shop by slug or ?shopId= ---
        String slug = extractSlug(req); // from /vendor/{slug}
        Long shopIdQuery = parseLong(req.getParameter("shopId"));
        Shop shop = shopService.findBySlugOrId(slug, shopIdQuery);

        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Shop không tồn tại hoặc không khả dụng.");
            return;
        }

        Long shopId = shop.getShopId();

        // --- Filters y chang trang /products ---
        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), 12);
        String q = trimToNull(req.getParameter("q"));
        Long categoryId = parseLong(req.getParameter("catId"));
        // sort, price range, rating ... có thể được thêm sau; tạm giữ param để view tái sử dụng
        String sort = trimToNull(req.getParameter("sort"));
        String minPrice = trimToNull(req.getParameter("minPrice"));
        String maxPrice = trimToNull(req.getParameter("maxPrice"));
        String minRating = trimToNull(req.getParameter("minRating"));

        // --- Query products: chỉ ACTIVE, phân trang ---
        ProductService.PageResult<Product> pageResult =
                productService.findByShopPaged(
                        shopId,
                        page,
                        size,
                        q,
                        categoryId,
                        Product.ProductStatus.ACTIVE
                );

        // --- Set attributes for JSP reuse (giữ tên gần giống /products) ---
        req.setAttribute("shop", shop);
        req.setAttribute("page", pageResult);          // page.items, page.page, page.size, page.totalPages
        req.setAttribute("pageTitle", shop.getShopName());

        // giữ lại toàn bộ params để form/pagination không mất ngữ cảnh
        req.setAttribute("q", q);
        req.setAttribute("catId", categoryId);
        req.setAttribute("sort", sort);
        req.setAttribute("minPrice", minPrice);
        req.setAttribute("maxPrice", maxPrice);
        req.setAttribute("minRating", minRating);

        // để view luôn kèm ngữ cảnh shop
        req.setAttribute("shopId", shopId);
        req.setAttribute("shopSlug", slug);

        // --- Forward view (FE sẽ tái dùng UI /products) ---
        req.getRequestDispatcher("/WEB-INF/views/public/shop-products.jsp").forward(req, resp);
    }

    private static String extractSlug(HttpServletRequest req) {
        // mapping /vendor/* → getPathInfo() = "/{slug}" hoặc null
        String path = req.getPathInfo();
        if (path == null || path.isBlank() || "/".equals(path)) return null;
        String s = path;
        if (s.startsWith("/")) s = s.substring(1);
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static int parseInt(String s, int defVal) {
        try { return Integer.parseInt(s); } catch (Exception e) { return defVal; }
    }
    private static Long parseLong(String s) {
        try { return (s == null || s.isBlank()) ? null : Long.valueOf(s.trim()); }
        catch (Exception e) { return null; }
    }
    private static String trimToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
