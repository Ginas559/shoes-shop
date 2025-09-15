package vn.iotstar.dao;

import java.util.List;
import vn.iotstar.configs.JPAConfig;
import vn.iotstar.entity.User;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

public class UserDAO {

    public User checkLogin(String email, String passwordHash) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email AND u.passwordHash = :passwordHash",
                User.class
            );
            query.setParameter("email", email);
            query.setParameter("passwordHash", passwordHash);

            List<User> users = query.getResultList();
            return users.isEmpty() ? null : users.get(0);
        } finally {
            em.close();
        }
    }
}
