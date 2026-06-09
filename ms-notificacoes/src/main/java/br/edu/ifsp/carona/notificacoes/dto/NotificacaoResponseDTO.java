package br.edu.ifsp.carona.notificacoes.dto;

import br.edu.ifsp.carona.notificacoes.entity.Notificacao;

import java.time.LocalDateTime;

public record NotificacaoResponseDTO(
        Long id,
        Long destinatarioId,
        String tipo,
        String titulo,
        String mensagem,
        Boolean lida,
        LocalDateTime criadoEm
) {
    public static NotificacaoResponseDTO fromEntity(Notificacao n) {
        return new NotificacaoResponseDTO(
                n.getId(),
                n.getDestinatarioId(),
                n.getTipo() != null ? n.getTipo().name() : null,
                n.getTitulo(),
                n.getMensagem(),
                n.getLida(),
                n.getCriadoEm()
        );
    }
}
