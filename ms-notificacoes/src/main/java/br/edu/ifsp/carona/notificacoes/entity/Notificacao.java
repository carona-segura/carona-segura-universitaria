package br.edu.ifsp.carona.notificacoes.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "notificacoes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notificacao {

    public enum Tipo {
        USUARIO_CADASTRADO,
        VIAGEM_CRIADA,
        PASSAGEIRO_ENTROU
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long destinatarioId;

    @Enumerated(EnumType.STRING)
    private Tipo tipo;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String mensagem;

    @Builder.Default
    private Boolean lida = false;

    private String dadosExtras;

    @CreationTimestamp
    private LocalDateTime criadoEm;
}
