// filepath: src/main/java/vn/iotstar/services/ProductVariantService.java
package vn.iotstar.services;

import java.util.List;
import vn.iotstar.DAO.ProductVariantDAO;
import vn.iotstar.entities.Product;
import vn.iotstar.entities.ProductVariant;

public class ProductVariantService {

    private final ProductVariantDAO dao = new ProductVariantDAO();

    public void addVariant(ProductVariant variant) {
        dao.save(variant);
    }

    public List<ProductVariant> listByProduct(Product product) {
        return dao.findByProduct(product);
    }

    public void deleteVariant(Long variantId) {
        dao.delete(variantId);
    }
}
