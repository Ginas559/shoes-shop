package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import vn.iotstar.entities.Product;
import vn.iotstar.services.ProductService;

import vn.iotstar.services.CategoryService;

@WebServlet(urlPatterns = {"/vendor/products", "/vendor/products/*"})
public class VendorProductServlet extends HttpServlet {
    private final ProductService productService = new ProductService();
    
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        if (path == null || "/".equals(path)) {
            // List sản phẩm của shop hiện tại
            List<Product> list = productService.getByVendor(req);
            req.setAttribute("products", list);

            // Nạp danh mục để hiển thị dropdown
            req.setAttribute("categories", categoryService.findAll());

            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp")
               .forward(req, resp);
            return;
        }

        if ("/edit".equals(path)) {
            Long id = Long.valueOf(req.getParameter("id"));
            req.setAttribute("p", productService.findById(id));

            // Nạp danh mục để chọn lại khi sửa
            req.setAttribute("categories", categoryService.findAll());

            req.getRequestDispatcher("/WEB-INF/views/vendor/products.jsp")
               .forward(req, resp);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if ("/add".equals(path)) {
            productService.add(req);
            resp.sendRedirect(req.getContextPath() + "/vendor/products");
            return;
        }
        if ("/update".equals(path)) {
            productService.update(req);
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
}
