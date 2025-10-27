// filepath: src/main/java/vn/iotstar/controllers/vendor/VendorProductServlet.java
package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import vn.iotstar.configs.CloudinaryConfig;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.User;
import vn.iotstar.services.CategoryService;
import vn.iotstar.services.ProductImageService;
import vn.iotstar.services.ProductService;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/products", "/vendor/products/*"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class VendorProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();
    private final ProductImageService productImageService = new ProductImageService();
    private final StatisticService helper = new StatisticService();

    /** Resolve shop cho owner/staff. Đồng bộ staffShopId nếu cần. */
    private Shop resolveShop(HttpServletRequest req) {
        Long uid  = SessionUtil.currentUserId(req);
        String role = SessionUtil.currentRole(req);
        HttpSession ss = req.getSession(false);
        Long staffShopId = (ss != null && ss.getAttribute("staffShopId") != null)
                ? (Long) ss.getAttribute("staffShopId") : null;

        if ("VENDOR".equals(role)) {
            return helper.findShopByOwner(uid);
        }
        if ("USER".equals(role)) {
            Long sid = staffShopId;
            if (sid == null && ss != null) {
                Object cu = ss.getAttribute("currentUser");
                if (cu instanceof User u && u.getStaffShop() != null) {
                    sid = u.getStaffShop().getShopId();
                    ss.setAttribute("staffShopId", sid);
                }
            }
            return (sid != null) ? helper.findShopById(sid) : null;
        }
        return null;
    }

    private void ensureOwned(Shop shop, Product p, HttpServletResponse resp) throws IOException {
        if (p == null || shop == null || p.getShop() == null
                || !Objects.equals(p.getShop().getShopId(), shop.getShopId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền thao tác sản phẩm này.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        Shop shop = resolveShop(req);
        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không xác định được shop.");
            return;
        }
        req.setAttribute("shop", shop);

        if (path == null || "/".equals(path)) {
            // chỉ lấy sản phẩm của shop hiện tại
            List<Product> list = productService.getByShopId(shop.getShopId());
            req.setAttribute("products", list);

            Map<Long, String> thumbnails = new HashMap<>();
            for (Product p : list) {
                thumbnails.put(p.getProductId(), productImageService.getThumbnailUrl(p.getProductId()));
            }
            req.setAttribute("thumbnails", thumbnails);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp").forward(req, resp);
            return;
        }

        if ("/edit".equals(path)) {
            Long id = Long.valueOf(req.getParameter("id"));
            Product p = productService.findById(id);
            ensureOwned(shop, p, resp); if (resp.isCommitted()) return;

            req.setAttribute("p", p);
            req.setAttribute("categories", categoryService.findAll());
            req.setAttribute("thumbEditing", productImageService.getThumbnailUrl(id));
            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp").forward(req, resp);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        Shop shop = resolveShop(req);
        if (shop == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không xác định được shop.");
            return;
        }

        if ("/add".equals(path)) {
            Long productId = productService.addForShop(req, shop.getShopId()); // gán shopId tại server
            Part part = req.getPart("image");
            if (part != null && part.getSize() > 0) {
                String url = uploadToCloudinary(part);
                productImageService.addImage(productId, url, true);
            }
            resp.sendRedirect(req.getContextPath() + "/vendor/products");
            return;
        }

        if ("/update".equals(path)) {
            Long productId = Long.valueOf(req.getParameter("productId"));
            Product p = productService.findById(productId);
            ensureOwned(shop, p, resp); if (resp.isCommitted()) return;

            productService.updateForShop(req, shop.getShopId());   // đảm bảo chỉ cập nhật trong shop
            Part part = req.getPart("image");
            if (part != null && part.getSize() > 0) {
                String url = uploadToCloudinary(part);
                productImageService.clearThumbnail(productId);
                productImageService.addImage(productId, url, true);
            }
            resp.sendRedirect(req.getContextPath() + "/vendor/products");
            return;
        }

        if ("/delete".equals(path)) {
            Long id = Long.valueOf(req.getParameter("productId"));
            Product p = productService.findById(id);
            ensureOwned(shop, p, resp); if (resp.isCommitted()) return;

            productService.softDelete(id);
            resp.sendRedirect(req.getContextPath() + "/vendor/products");
            return;
        }

        resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private String uploadToCloudinary(Part part) throws IOException {
        Cloudinary cloud = CloudinaryConfig.getCloudinary();
        try (InputStream is = part.getInputStream()) {
            byte[] data = is.readAllBytes();
            Map<?, ?> res = cloud.uploader().upload(
                data,
                ObjectUtils.asMap(
                    "folder", "shoes-shop/products",
                    "resource_type", "image"
                )
            );
            return String.valueOf(res.get("secure_url"));
        }
    }
}
