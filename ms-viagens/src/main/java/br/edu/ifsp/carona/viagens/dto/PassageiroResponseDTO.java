package br.edu.ifsp.carona.viagens.dto;

import br.edu.ifsp.carona.viagens.entity.Passageiro;

import java.time.LocalDateTime;

public record PassageiroResponseDTO(
        Long id,
        Long viagemId,
        Long passageiroId,
        String status,
        LocalDateTime reservadoEm
) {
    public static PassageiroResponseDTO fromEntity(Passageiro p) {
        return new PassageiroResponseDTO(
                p.getId(),
                p.getViagemId(),
                p.getPassageiroId(),
                p.getStatus().name(),
                p.getReservadoEm()
        );
    }
}
