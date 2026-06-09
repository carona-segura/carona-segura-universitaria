package br.edu.ifsp.carona.viagens.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "viagens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Viagem {

    public enum Status {
        ABERTA, EM_ANDAMENTO, CONCLUIDA, CANCELADA
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long motoristaId;

    @Column(nullable = false)
    private String origem;

    @Column(nullable = false)
    private String destino;

    @Column(nullable = false)
    private LocalDateTime dataHoraSaida;

    @Column(nullable = false)
    private Integer vagas;

    @Builder.Default
    private Integer vagasOcupadas = 0;

    @Column(nullable = false)
    private BigDecimal valorContribuicao;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Status status = Status.ABERTA;

    @CreationTimestamp
    private LocalDateTime criadoEm;

    @UpdateTimestamp
    private LocalDateTime atualizadoEm;
}
