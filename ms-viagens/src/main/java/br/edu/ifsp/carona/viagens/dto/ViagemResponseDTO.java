package br.edu.ifsp.carona.viagens.dto;

import br.edu.ifsp.carona.viagens.entity.Viagem;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ViagemResponseDTO(
        Long id,
        Long motoristaId,
        String origem,
        String destino,
        LocalDateTime dataHoraSaida,
        Integer vagas,
        Integer vagasOcupadas,
        BigDecimal valorContribuicao,
        String status,
        LocalDateTime criadoEm
) {
    public static ViagemResponseDTO fromEntity(Viagem v) {
        return new ViagemResponseDTO(
                v.getId(),
                v.getMotoristaId(),
                v.getOrigem(),
                v.getDestino(),
                v.getDataHoraSaida(),
                v.getVagas(),
                v.getVagasOcupadas(),
                v.getValorContribuicao(),
                v.getStatus().name(),
                v.getCriadoEm()
        );
    }
}
