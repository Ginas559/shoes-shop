// tung - filepath: src/main/java/vn/iotstar/repositories/UserOtpRepository.java
package vn.iotstar.repositories;

import jakarta.persistence.*;
import vn.iotstar.entities.UserOtp;

import java.time.LocalDateTime;

public class UserOtpRepository {

    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("default");

    public void save(UserOtp otp) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(otp);
            em.getTransaction().commit();
        } finally {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            em.close();
        }
    }

    public UserOtp findLatestActive(Long userId, UserOtp.Purpose purpose) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<UserOtp> q = em.createQuery(
                "SELECT o FROM UserOtp o WHERE o.userId = :uid AND o.purpose = :p AND o.usedAt IS NULL " +
                "AND o.expiresAt > :now ORDER BY o.id DESC", UserOtp.class);
            q.setParameter("uid", userId);
            q.setParameter("p", purpose);
            q.setParameter("now", LocalDateTime.now());
            q.setMaxResults(1);
            return q.getResultList().stream().findFirst().orElse(null);
        } finally {
            em.close();
        }
    }

    public void markUsed(Long otpId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            UserOtp o = em.find(UserOtp.class, otpId);
            if (o != null) {
                o.setUsedAt(LocalDateTime.now());
                em.merge(o);
            }
            em.getTransaction().commit();
        } finally {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            em.close();
        }
    }
}
