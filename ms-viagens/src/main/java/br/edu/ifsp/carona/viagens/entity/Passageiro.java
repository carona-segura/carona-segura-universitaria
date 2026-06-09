package br.edu.ifsp.carona.viagens.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "passageiros")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Passageiro {

    public enum StatusPassageiro {
        PENDENTE, CONFIRMADO, CANCELADO
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long viagemId;

    @Column(nullable = false)
    private Long passageiroId;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private StatusPassageiro status = StatusPassageiro.PENDENTE;

    @CreationTimestamp
    private LocalDateTime reservadoEm;
}
