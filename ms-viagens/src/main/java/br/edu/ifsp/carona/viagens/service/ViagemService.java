package br.edu.ifsp.carona.viagens.service;

import br.edu.ifsp.carona.viagens.config.RabbitMQConfig;
import br.edu.ifsp.carona.viagens.dto.*;
import br.edu.ifsp.carona.viagens.entity.Passageiro;
import br.edu.ifsp.carona.viagens.entity.Viagem;
import br.edu.ifsp.carona.viagens.repository.PassageiroRepository;
import br.edu.ifsp.carona.viagens.repository.ViagemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ViagemService {

    private final ViagemRepository viagemRepository;
    private final PassageiroRepository passageiroRepository;
    private final UsuarioClientService usuarioClientService;
    private final RabbitTemplate rabbitTemplate;

    public ViagemResponseDTO criar(ViagemRequestDTO dto) {
        UsuarioClientDTO usuario = usuarioClientService.buscarUsuario(dto.motoristaId());

        if (!Boolean.TRUE.equals(usuario.motorista())) {
            throw new IllegalArgumentException("Usuário não é motorista");
        }

        Viagem viagem = Viagem.builder()
                .motoristaId(dto.motoristaId())
                .origem(dto.origem())
                .destino(dto.destino())
                .dataHoraSaida(dto.dataHoraSaida())
                .vagas(dto.vagas())
                .valorContribuicao(dto.valorContribuicao())
                .build();

        viagemRepository.save(viagem);

        rabbitTemplate.convertAndSend(
                RabbitMQConfig.EXCHANGE,
                RabbitMQConfig.ROUTING_KEY_VIAGEM_CRIADA,
                Map.of(
                        "motoristaId", viagem.getMotoristaId().toString(),
                        "origem", viagem.getOrigem(),
                        "destino", viagem.getDestino(),
                        "dataHoraSaida", viagem.getDataHoraSaida().toString()
                )
        );

        return ViagemResponseDTO.fromEntity(viagem);
    }

    public List<ViagemResponseDTO> listar() {
        return viagemRepository.findAll().stream()
                .map(ViagemResponseDTO::fromEntity)
                .toList();
    }

    public List<ViagemResponseDTO> listarAbertas() {
        return viagemRepository.findByStatus(Viagem.Status.ABERTA).stream()
                .map(ViagemResponseDTO::fromEntity)
                .toList();
    }

    public ViagemResponseDTO buscarPorId(Long id) {
        Viagem viagem = viagemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Viagem não encontrada com id: " + id));
        return ViagemResponseDTO.fromEntity(viagem);
    }

    public List<ViagemResponseDTO> buscarPorMotorista(Long motoristaId) {
        return viagemRepository.findByMotoristaId(motoristaId).stream()
                .map(ViagemResponseDTO::fromEntity)
                .toList();
    }

    public List<ViagemResponseDTO> buscarPorRota(String origem, String destino) {
        return viagemRepository
                .findByOrigemContainingIgnoreCaseAndDestinoContainingIgnoreCase(origem, destino)
                .stream()
                .map(ViagemResponseDTO::fromEntity)
                .toList();
    }

    public ViagemResponseDTO cancelar(Long id) {
        Viagem viagem = viagemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Viagem não encontrada com id: " + id));

        if (viagem.getStatus() != Viagem.Status.ABERTA) {
            throw new IllegalArgumentException("Só é possível cancelar viagens abertas");
        }

        viagem.setStatus(Viagem.Status.CANCELADA);
        viagemRepository.save(viagem);
        return ViagemResponseDTO.fromEntity(viagem);
    }

    public PassageiroResponseDTO entrarNaViagem(Long viagemId, Long passageiroId) {
        Viagem viagem = viagemRepository.findById(viagemId)
                .orElseThrow(() -> new IllegalArgumentException("Viagem não encontrada com id: " + viagemId));

        if (viagem.getStatus() != Viagem.Status.ABERTA) {
            throw new IllegalArgumentException("Viagem não está aberta para reservas");
        }

        if (viagem.getVagasOcupadas() >= viagem.getVagas()) {
            throw new IllegalArgumentException("Viagem sem vagas disponíveis");
        }

        if (passageiroRepository.existsByViagemIdAndPassageiroId(viagemId, passageiroId)) {
            throw new IllegalArgumentException("Passageiro já está nesta viagem");
        }

        Passageiro passageiro = Passageiro.builder()
                .viagemId(viagemId)
                .passageiroId(passageiroId)
                .status(Passageiro.StatusPassageiro.CONFIRMADO)
                .build();

        viagem.setVagasOcupadas(viagem.getVagasOcupadas() + 1);
        viagemRepository.save(viagem);

        passageiroRepository.save(passageiro);

        rabbitTemplate.convertAndSend(
                RabbitMQConfig.EXCHANGE,
                RabbitMQConfig.ROUTING_KEY_VIAGEM_PASSAGEIRO,
                Map.of(
                        "viagemId", viagemId.toString(),
                        "passageiroId", passageiroId.toString(),
                        "acao", "ENTROU"
                )
        );

        return PassageiroResponseDTO.fromEntity(passageiro);
    }

    public List<PassageiroResponseDTO> listarPassageiros(Long viagemId) {
        return passageiroRepository.findByViagemId(viagemId).stream()
                .map(PassageiroResponseDTO::fromEntity)
                .toList();
    }
}
