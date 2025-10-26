package vn.iotstar.controllers.guest;

import vn.iotstar.services.ProductBrowseService;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

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

        // Lọc theo shop
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

        // Nạp danh sách shop cho ô lọc (có thể gõ để gợi ý)
        String shopQ = req.getParameter("shopQ");              // từ ô tìm shop
        var shops = svc.shops(shopQ);                          // trả về id, name

        List<Category> cats = svc.categories();

        req.setAttribute("pageTitle", "Sản phẩm");
        req.setAttribute("page", result);
        req.setAttribute("categories", cats);
        req.setAttribute("shopId", shopId);
        req.setAttribute("shops", shops);                      // <-- NEW
        req.setAttribute("shopQ", shopQ);                      // giữ lại giá trị đã gõ

        req.getRequestDispatcher("/WEB-INF/views/products/list.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo(); // "/{id}"
        Long id = (path==null || path.length()<2) ? null : parseLongObj(path.substring(1));
        if (id == null){ resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        Product p = svc.findById(id);
        if (p == null){ resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        req.setAttribute("pageTitle", p.getProductName());
        req.setAttribute("product", p);
        req.setAttribute("images", svc.imagesOf(p));
        req.getRequestDispatcher("/WEB-INF/views/products/detail.jsp").forward(req, resp);
    }

    // helpers
    private int parseInt(String s, int d){ try { return Integer.parseInt(s);}catch(Exception e){return d;}}
    private Integer parseIntObj(String s){ try { return (s==null||s.isBlank())?null:Integer.valueOf(s);}catch(Exception e){return null;}}
    private Long parseLongObj(String s){ try { return (s==null||s.isBlank())?null:Long.valueOf(s);}catch(Exception e){return null;}}
    private BigDecimal parseBD(String s){ try { return (s==null||s.isBlank())?null:new BigDecimal(s);}catch(Exception e){return null;}}
}
