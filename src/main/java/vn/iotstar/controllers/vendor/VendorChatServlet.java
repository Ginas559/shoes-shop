package vn.iotstar.controllers.vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/chat"})
public class VendorChatServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String shopId = req.getParameter("shopId");
        if (shopId == null || shopId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing shopId");
            return;
        }

        // Nếu có thông tin shop, set vào request để hiển thị tiêu đề (không bắt buộc)
        req.setAttribute("shopId", shopId);

        req.getRequestDispatcher("/WEB-INF/views/vendor/shop-chat.jsp")
           .forward(req, resp);
    }
}
