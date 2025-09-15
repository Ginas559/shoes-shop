package vn.iotstar.controller;

import java.io.IOException;
import java.util.Date;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.iotstar.entity.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private EntityManagerFactory emf;

    @Override
    public void init() throws ServletException {
        emf = Persistence.createEntityManagerFactory("dataSource");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullname = req.getParameter("fullname");

        EntityManager em = emf.createEntityManager();

        try {
            // Kiểm tra email tồn tại chưa
            long count = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                    .setParameter("email", email)
                    .getSingleResult();
            if (count > 0) {
                req.setAttribute("error", "Email đã tồn tại!");
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            // Tạo user mới
            User user = new User();
            user.setEmail(email);
            user.setPasswordHash(password); // ⚠️ TODO: sau này hash mật khẩu
            user.setFullName(fullname);
            user.setRole("USER");
            user.setStatus("ACTIVE");
            user.setCreatedAt(new Date());

            em.getTransaction().begin();
            em.persist(user);
            em.getTransaction().commit();

            req.setAttribute("message", "Đăng ký thành công! Hãy đăng nhập.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw new ServletException(e);
        } finally {
            em.close();
        }
    }

    @Override
    public void destroy() {
        emf.close();
    }
}
