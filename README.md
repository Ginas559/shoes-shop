Thanh Tùng chạy deloy: https://bmtt.onrender.com/products?shopId=2
# 👟 Shoes Shop — Java Servlet/JSP E‑Commerce

![Java](https://img.shields.io/badge/Java-17%2F21%2F24-blue)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10%2B-orange)
![Tomcat](https://img.shields.io/badge/Tomcat-10.x-yellow)
![Build](https://img.shields.io/badge/Build-Maven-brightgreen)
![DB](https://img.shields.io/badge/DB-SQL%20Server-9cf)

> Dự án thương mại điện tử bán giày với đầy đủ luồng mua sắm: duyệt sản phẩm → giỏ hàng → thanh toán → giao hàng → đánh giá; hỗ trợ đa vai trò **User / Vendor / Shipper / Admin**.  
> Tech chính: **Java Servlet & JSP (Jakarta)** + **JPA/Hibernate** + **SQL Server** + **Bootstrap** + **SiteMesh 3** + **Cloudinary** + **Jakarta Mail** + **VNPAY**.

---

## Mục lục

- [Giới thiệu](#giới-thiệu)
- [Ảnh chụp màn hình](#ảnh-chụp-màn-hình)
- [Kiến trúc & Thư mục](#kiến-trúc--thư-mục)
- [Cơ sở dữ liệu](#cơ-sở-dữ-liệu)
- [Cài đặt](#cài-đặt)
- [Cấu hình môi trường](#cấu-hình-môi-trường)
- [Chạy dự án](#chạy-dự-án)
- [Cách dùng & Ví dụ](#cách-dùng--ví-dụ)
- [Đóng góp](#đóng-góp)
- [Khắc phục lỗi & FAQ](#khắc-phục-lỗi--faq)
- [Phụ thuộc](#phụ-thuộc)
- [Hỗ trợ](#hỗ-trợ)
- [Công nhận](#công-nhận)
- [Tài liệu tham khảo](#tài-liệu-tham-khảo)
- [Giấy phép](#giấy-phép)
- [Lịch sử thay đổi](#lịch-sử-thay-đổi)
- [Những lỗi đã biết](#những-lỗi-đã-biết)

---

## Giới thiệu

**Shoes Shop** là website thương mại điện tử cho phép:
- Người dùng: đăng ký/đăng nhập (OTP), quản lý hồ sơ & địa chỉ, thêm sản phẩm vào giỏ, đặt hàng, theo dõi đơn, đánh giá/bình luận, yêu thích & lịch sử đã xem.
- Vendor (chủ shop): quản lý sản phẩm/khuyến mãi/coupon/đơn hàng/nhân viên, thống kê.
- Shipper: nhận & cập nhật trạng thái giao hàng.
- Admin: phê duyệt/ban shop, quản lý người dùng, danh mục, sản phẩm.

Các URL chính (đã cấu hình trong `WEB-INF/web.xml`):
- `GET /products` — duyệt danh sách sản phẩm
- `GET /product/{slug|id}` — xem chi tiết
- `GET/POST /cart` & `/cart/*` — giỏ hàng
- `GET/POST /checkout` — thanh toán
- `GET /orders` & `GET /order/{id}` — đơn hàng
- `GET /recent` — sản phẩm đã xem
- `POST /favorite/toggle`, `GET /favorites` — yêu thích
- `GET /user/profile`, `GET/POST /user/addresses`, `GET/POST /user/address/{id}` — hồ sơ & địa chỉ

> Ngoài ra còn có các module Admin/Vendor/Shipper riêng trong `src/main/java/vn/iotstar/controllers/...` với nhiều chức năng quản trị.

---

## Ảnh chụp màn hình

> (Tuỳ chọn) Thêm ảnh thật của dự án để trực quan hơn:  
> `src/main/webapp/assets/img/...`  
> Ví dụ: trang danh sách sản phẩm, giỏ hàng, trang admin.  
> _Mẹo:_ Dùng GIF hoặc video ngắn minh hoạ luồng mua hàng.

---

## Kiến trúc & Thư mục

- **Mô hình:** MVC (Servlet Controller → Service/DAO → JSP View + JSTL)
- **Bố cục giao diện:** SiteMesh 3 (layouts cho web, admin, shipper, auth)
- **Tầng dữ liệu:** JPA/Hibernate (`persistence.xml`) + SQL Server
- **Upload media:** Cloudinary
- **Thanh toán:** Tích hợp **VNPAY** (COD & MOMO có sẵn trong schema; MoMo có thể bổ sung sau)

Cây thư mục (rút gọn):

```
shoes-shop/
├─ pom.xml
├─ src/main/java/vn/iotstar/
│  ├─ configs/            # JPAConfig, CloudinaryConfig, VnPayConfig
│  ├─ controllers/
│  │  ├─ admin/           # Quản trị: product, category, order, coupon, promotion...
│  │  ├─ auth/            # Login, Register, OTP, Forgot/Reset password
│  │  ├─ guest/           # Duyệt SP, yêu thích, đã xem
│  │  ├─ order/           # Cart, Checkout, Order
│  │  ├─ shipper/         # Shipper nhận/giao đơn
│  │  ├─ user/            # Hồ sơ, địa chỉ
│  │  └─ vendor/          # Quản trị shop, sản phẩm, variant, sale, voucher, staff
│  ├─ entities/           # JPA Entities khớp DB
│  └─ services/           # Business logic (Mail, VnPay, Product, Order,...)
├─ src/main/resources/META-INF/persistence.xml
└─ src/main/webapp/
   ├─ WEB-INF/web.xml     # Định tuyến Servlet + SiteMesh
   ├─ WEB-INF/views/      # JSP Views (web/admin/shipper/auth/...)
   ├─ WEB-INF/decorators/ # Layouts
   └─ assets/             # CSS/JS/IMG/Uploads
```

---

## Cơ sở dữ liệu

- Hệ quản trị: **Microsoft SQL Server**
- Tên DB: `shoesshop`
- Các nhóm bảng chính:
  - **Người dùng & xác thực:** `users`, `user_otp`, `User_Verification`, `Address`
  - **Sản phẩm & phân loại:** `Product`, `Category`, `Product_Image`, `Product_Review`, `Product_Comment`, `Product_Review_Image`
  - **Giỏ hàng & đặt hàng:** `Cart`, `Cart_Item`, `Order`, `Order_Item`, `Order_Status_History`, `Payment`
  - **Shop & ví:** `Shop`, `Shop_Member`, `Wallet`, `Wallet_Transaction`
  - **Ưu đãi:** `Promotion`, `Coupon`
  - **Khác:** `Favorite`, `Viewed_Product`, `Shipping_Partner`, `Shipper`

> Lược đồ, ràng buộc khoá ngoại, CHECK constraints (trạng thái đơn, phương thức thanh toán, v.v.) đã có sẵn trong script SQL đi kèm. Hãy import trước khi chạy dự án (xem phần **Cài đặt**).
 
---

## Cài đặt

### Yêu cầu hệ thống
| Thành phần | Phiên bản khuyến nghị |
|---|---|
| JDK | **17** hoặc **21** (dự án hiện cấu hình Maven cho Java 24; nếu Tomcat/JRE thấp hơn vui lòng hạ xuống 17/21) |
| Apache Tomcat | **10.x** (Jakarta) |
| SQL Server | 2019+ |
| Maven | 3.9+ |

### Bước 1 — Import cơ sở dữ liệu
1. Mở SQL Server Management Studio.
2. Chạy script tạo DB & bảng từ file `all_DTb_have.sql`.
3. Kiểm tra DB `shoesshop` đã có đầy đủ bảng, FK & constraints.

### Bước 2 — Cấu hình JDBC (JPA/Hibernate)
Mở `src/main/resources/META-INF/persistence.xml` và điều chỉnh:
```xml
<property name="jakarta.persistence.jdbc.url" value="jdbc:sqlserver://localhost:1433;databaseName=shoesshop;encrypt=true;trustServerCertificate=true;"/>
<property name="jakarta.persistence.jdbc.user" value="sa"/>
<property name="jakarta.persistence.jdbc.password" value="your_password"/>
<!-- Nên dùng: -->
<property name="hibernate.hbm2ddl.auto" value="none"/>
```
> Vì đã có script SQL, **khuyến nghị** đặt `hbm2ddl.auto=none` để tránh Hibernate tự sửa schema.

### Bước 3 — Cấu hình Cloudinary & Mail
Tạo file `.env` ở root (không commit secrets) và điền:
```
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@example.com
MAIL_PASSWORD=app_password
```
> `CloudinaryConfig` & `MailService` sẽ đọc các biến môi trường này.

### Bước 4 — Build & Deploy
```bash
# Build WAR
mvn clean package

# Deploy lên Tomcat 10.x
#   - Copy target/ShoesShop.war vào $TOMCAT/webapps/
#   - Hoặc cấu hình Artifacts trong IntelliJ/Eclipse để run trực tiếp
```

---

## Cấu hình môi trường

- **Java version:** Dự án đang set `<maven.compiler.source/target> = 24`.  
  Nếu máy bạn dùng JDK/Tomcat thấp hơn, cập nhật `pom.xml` về 21 hoặc 17 để tránh `Unsupported class file version`.
- **SQL Server:** Bật TCP/IP (port 1433). Nếu certificate chưa cấu hình, thêm `encrypt=true;trustServerCertificate=true;`.
- **Upload:** Tạo thư mục `src/main/webapp/uploads` (đã có sẵn) hoặc dùng Cloudinary.
- **SiteMesh 3:** Định nghĩa trong `WEB-INF/sitemesh3.xml` và filter trong `web.xml`.

---

## Chạy dự án

- Khởi chạy Tomcat → truy cập: `http://localhost:8080/ShoesShop`
- Một số đường dẫn:
  - Web: `/products`, `/product/*`, `/cart`, `/checkout`, `/orders`
  - User: `/user/profile`, `/user/addresses`
  - Admin: `/admin/*` (tuỳ controller)
  - Vendor: `/vendor/*`
  - Shipper: `/shipper/*`

> Tài khoản mẫu (nếu có seed): cập nhật theo dữ liệu thật của bạn.

---

## Cách dùng & Ví dụ

### Luồng mua hàng
1. Người dùng đăng nhập/đăng ký (OTP).
2. Duyệt sản phẩm → thêm vào giỏ `/cart`.
3. Thanh toán `/checkout` (COD hoặc qua VNPAY).
4. Theo dõi `/orders`, xem chi tiết `/order/{id}`.
5. Sau khi hoàn tất, có thể đánh giá 1 lần cho mỗi `order_item`.

### Ví dụ gọi đến **VNPAY**
- Service: `VnPayService` — tạo URL thanh toán
- Config: `VnPayConfig` — chữ ký, tham số chuẩn

---

## Đóng góp

1. Fork repository → tạo nhánh: `feature/ten-tinh-nang`
2. Viết code + test → đảm bảo build pass
3. Gửi Pull Request kèm mô tả rõ ràng
4. Quy tắc chấp nhận:
   - Không để lộ secrets
   - Tuân theo cấu trúc MVC
   - Không phá vỡ schema DB & ràng buộc
   - Cập nhật README nếu thay đổi hành vi

---

## Khắc phục lỗi & FAQ

**1) `java.lang.NoSuchMethodError: jakarta.servlet...`**  
→ Dùng **Tomcat 10.x** trở lên (Jakarta), không phải Tomcat 9 (javax).

**2) `Unsupported class file version`**  
→ Hạ `maven.compiler.source/target` về **17/21** hoặc cài JDK phù hợp.

**3) Không kết nối SQL Server**  
- Bật TCP/IP, mở port 1433
- Kiểm tra user/password
- Thêm `encrypt=true;trustServerCertificate=true;` nếu chưa cấu hình SSL

**4) Hibernate tự sửa bảng**  
→ Đặt `hibernate.hbm2ddl.auto=none` khi đã import schema thủ công.

**5) Ảnh không hiển thị/Upload lỗi**  
→ Kiểm tra `.env` Cloudinary; đảm bảo key hợp lệ và không commit lên Git.

**6) OTP không gửi**  
→ Bật “Less secure app” (nếu dùng Gmail App Password), cấu hình đúng host/port TLS 587.

---

## Phụ thuộc

Các thư viện chính (trích `pom.xml`):
- `com.microsoft.sqlserver:mssql-jdbc`
- `jakarta.servlet:jakarta.servlet-api` (scope provided)
- `jakarta.servlet.jsp:jakarta.servlet.jsp-api` (provided)
- `org.glassfish.web:jakarta.servlet.jsp.jstl`
- `org.hibernate.orm:hibernate-core`
- `org.projectlombok:lombok`
- `com.sun.mail:jakarta.mail`, `com.sun.activation:jakarta.activation`
- `org.mindrot:jbcrypt`
- `org.sitemesh:sitemesh` (SiteMesh 3)
- `ch.qos.logback:logback-classic`
- `com.zaxxer:HikariCP`
- `org.apache.commons:commons-lang3`
- `com.cloudinary:cloudinary-http44`
- `io.github.cdimascio:dotenv-java`

> Xem đầy đủ và phiên bản cụ thể trong `pom.xml` của dự án.

---

## Hỗ trợ

- **Liên hệ:** (điền email/Discord/Zalo của nhóm)
- **Vấn đề/Bug:** mở issue trên GitHub với template: mô tả, bước tái hiện, log.

---

## Công nhận

- Đội ngũ phát triển dự án Shoes Shop
- Cộng đồng mã nguồn mở: Jakarta EE, Hibernate, SiteMesh, Cloudinary, VNPAY

---

## Tài liệu tham khảo

- Jakarta Servlet/JSP/JSTL, Hibernate ORM
- Tài liệu VNPAY, Cloudinary
- SQL Server Docs

---

## Giấy phép

Chọn 1: MIT / Apache-2.0 / GPL-3.0…  
Thêm file `LICENSE` tương ứng ở root repo.

---

## Lịch sử thay đổi

- **v1.0.0**: Khởi tạo dự án, các luồng User/Vendor/Shipper/Admin cơ bản.
- (Cập nhật tiếp…)

---

## Những lỗi đã biết

- Chưa chuẩn hoá toàn bộ thông báo lỗi người dùng
- Chưa có test tự động E2E
- Mới tích hợp VNPAY; MoMo có trong schema nhưng chưa có service hoàn chỉnh

---

## Huy hiệu (tùy chọn)

- Build CI (GitHub Actions)
- Code Coverage
- Lint/Style

> Gợi ý: thêm workflow GitHub Actions để build Maven + deploy WAR.
