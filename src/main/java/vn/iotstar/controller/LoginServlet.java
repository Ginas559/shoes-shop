package vn.iotstar.controller;

import java.io.IOException;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EntityManagerFactory emf;

    @Override
    public void init() throws ServletException {
        emf = Persistence.createEntityManagerFactory("dataSource");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password"); // TODO: hash nếu cần

        EntityManager em = emf.createEntityManager();

        try {
            User user = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email AND u.passwordHash = :password", User.class)
                .setParameter("email", email)
                .setParameter("password", password)
                .getResultStream().findFirst().orElse(null);

            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("currentUser", user);

                // Redirect theo role
                switch (user.getRole()) {
                    case "ADMIN":
                        resp.sendRedirect(req.getContextPath() + "/admin/categories");
                        break;
                    case "VENDOR":
                        resp.sendRedirect(req.getContextPath() + "/vendor/products");
                        break;
                    case "SHIPPER":
                        resp.sendRedirect(req.getContextPath() + "/shipper/orders");
                        break;
                    default:
                        resp.sendRedirect(req.getContextPath() + "/home");
                        break;
                }
            } else {
                req.setAttribute("error", "Sai email hoặc mật khẩu!");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            }
        } finally {
            em.close();
        }
    }

    @Override
    public void destroy() {
        emf.close();
    }
}
