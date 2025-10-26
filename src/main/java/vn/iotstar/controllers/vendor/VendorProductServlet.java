// src/main/java/vn/iotstar/controllers/vendor/VendorProductServlet.java
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
import vn.iotstar.services.CategoryService;
import vn.iotstar.services.ProductImageService;
import vn.iotstar.services.ProductService;
import vn.iotstar.services.StatisticService;
import vn.iotstar.utils.SessionUtil;

@WebServlet(urlPatterns = {"/vendor/products", "/vendor/products/*"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB
public class VendorProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();
    private final ProductImageService productImageService = new ProductImageService();
    private final StatisticService helper = new StatisticService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        // Tên shop để hiển thị góc trên
        Long uid = SessionUtil.currentUserId(req);
        Shop shop = (uid != null) ? helper.findShopByOwner(uid) : null;
        req.setAttribute("shop", shop);

        if (path == null || "/".equals(path)) {
            List<Product> list = productService.getByVendor(req);
            req.setAttribute("products", list);

            // gom thumbnails theo productId -> url
            Map<Long, String> thumbnails = new HashMap<>();
            for (Product p : list) {
                thumbnails.put(p.getProductId(),
                        productImageService.getThumbnailUrl(p.getProductId()));
            }
            req.setAttribute("thumbnails", thumbnails);

            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp").forward(req, resp);
            return;
        }

        if ("/edit".equals(path)) {
            Long id = Long.valueOf(req.getParameter("id"));
            Product p = productService.findById(id);
            req.setAttribute("p", p);
            req.setAttribute("categories", categoryService.findAll());

            // preview thumbnail cho sản phẩm đang sửa
            String thumb = productImageService.getThumbnailUrl(id);
            req.setAttribute("thumbEditing", thumb);

            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp").forward(req, resp);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        if ("/add".equals(path)) {
            Long productId = productService.add(req);

            Part part = req.getPart("image");
            if (part != null && part.getSize() > 0) {
                String url = uploadToCloudinary(part);
                productImageService.addImage(productId, url, true);
            }

            resp.sendRedirect(req.getContextPath() + "/vendor/products");
            return;
        }

        if ("/update".equals(path)) {
            productService.update(req);

            Long productId = Long.valueOf(req.getParameter("productId"));
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
