package vn.iotstar.services.admin;

import java.util.List;


import vn.iotstar.DAO.IOrderDao;
import vn.iotstar.DAO.Impl.OrderDaoImpl;
import vn.iotstar.entities.Category;
import vn.iotstar.entities.Order;
import vn.iotstar.entities.Shop;
import vn.iotstar.entities.Order.OrderStatus;

public class AdminOrderService {
	private IOrderDao orderDao = new OrderDaoImpl();
	
	public List<Order> searchOrders(OrderStatus status, Shop shop, Category category, int page, int pageSize){
		return orderDao.searchOrders(status, shop, category, page, pageSize);
	}
	
	public int countOrders(OrderStatus status, Shop shop, Category category) {
		return orderDao.countOrders(status, shop, category);
	}
}
