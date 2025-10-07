package vn.shoeshop.Entities;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "[Category]")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Long categoryId;

    @Column(name = "category_name", nullable = false, length = 100)
    private String categoryName;

    @Column(name = "description", length = 500)
    private String description;
}
