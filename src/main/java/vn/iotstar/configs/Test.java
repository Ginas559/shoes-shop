package vn.iotstar.configs;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

public class Test {
	public static void main(String[] args) {
        EntityManager enma = JPAConfig.getEntityManager();
        enma.close(); // chỉ cần mở kết nối rồi đóng lại
    }
}
