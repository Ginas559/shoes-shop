package vn.iotstar.controller.vendor;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.iotstar.dao.ProductDAO;
import vn.iotstar.entity.Product;

@WebServlet("/vendor/products")
public class ProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO dao = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        List<Product> list = dao.findTopProducts(12);
        req.setAttribute("products", list);
        req.getRequestDispatcher("/WEB-INF/views/vendor/products-list.jsp")
           .forward(req, resp);
    }
}
