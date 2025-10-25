package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import vn.iotstar.entities.Product;
import vn.iotstar.services.ProductService;
import vn.iotstar.services.CategoryService;
import vn.iotstar.services.ProductImageService;
import vn.iotstar.configs.*;

@WebServlet(urlPatterns = {"/vendor/products", "/vendor/products/*"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB
public class VendorProductServlet extends HttpServlet {
    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();
    private final ProductImageService productImageService = new ProductImageService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        if (path == null || "/".equals(path)) {
            List<Product> list = productService.getByVendor(req);
            req.setAttribute("products", list);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp").forward(req, resp);
            return;
        }

        if ("/edit".equals(path)) {
            Long id = Long.valueOf(req.getParameter("id"));
            req.setAttribute("p", productService.findById(id));
            req.setAttribute("categories", categoryService.findAll());
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
            // 1) Tạo product -> nhận về productId
        	Long productId = productService.add(req); // giờ đã trả về ID

            // 2) Nếu có file ảnh -> upload Cloudinary -> lưu Product_Image
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
                // bỏ tick thumbnail cũ & set ảnh mới là thumbnail
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
            // Đọc input stream thành byte array
            byte[] data = is.readAllBytes();

            Map<?, ?> res = cloud.uploader().upload(data, ObjectUtils.asMap(
                    "folder", "shoes-shop/products",
                    "resource_type", "image"
            ));
            return String.valueOf(res.get("secure_url"));
        }
    }

}
