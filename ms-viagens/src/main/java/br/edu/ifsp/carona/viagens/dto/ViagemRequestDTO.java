package br.edu.ifsp.carona.viagens.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ViagemRequestDTO(

        @NotNull(message = "ID do motorista é obrigatório")
        Long motoristaId,

        @NotBlank(message = "Origem é obrigatória")
        String origem,

        @NotBlank(message = "Destino é obrigatório")
        String destino,

        @NotNull(message = "Data e hora de saída são obrigatórias")
        @Future(message = "Data de saída deve ser no futuro")
        LocalDateTime dataHoraSaida,

        @NotNull(message = "Número de vagas é obrigatório")
        @Min(value = 1, message = "Mínimo de 1 vaga")
        @Max(value = 4, message = "Máximo de 4 vagas")
        Integer vagas,

        @NotNull(message = "Valor de contribuição é obrigatório")
        @DecimalMin(value = "0.0", message = "Valor não pode ser negativo")
        BigDecimal valorContribuicao
) {}
