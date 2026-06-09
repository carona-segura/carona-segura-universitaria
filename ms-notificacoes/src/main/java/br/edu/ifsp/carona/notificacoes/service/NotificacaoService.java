package br.edu.ifsp.carona.notificacoes.service;

import br.edu.ifsp.carona.notificacoes.dto.NotificacaoResponseDTO;
import br.edu.ifsp.carona.notificacoes.entity.Notificacao;
import br.edu.ifsp.carona.notificacoes.repository.NotificacaoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificacaoService {

    private final NotificacaoRepository notificacaoRepository;

    public void processarNovoUsuario(Map<String, Object> dados) {
        String email = String.valueOf(dados.get("email"));
        String nome = String.valueOf(dados.get("nome"));

        Notificacao notificacao = Notificacao.builder()
                .destinatarioId(null)
                .tipo(Notificacao.Tipo.USUARIO_CADASTRADO)
                .titulo("Novo usuário cadastrado")
                .mensagem("Usuário " + nome + " (" + email + ") se cadastrou na plataforma.")
                .dadosExtras(dados.toString())
                .build();

        notificacaoRepository.save(notificacao);
        log.info("Notificação processada: novo usuário - {}", email);
    }

    public void processarViagemCriada(Map<String, Object> dados) {
        Long motoristaId = Long.parseLong(dados.get("motoristaId").toString());
        String origem = String.valueOf(dados.get("origem"));
        String destino = String.valueOf(dados.get("destino"));

        Notificacao notificacao = Notificacao.builder()
                .destinatarioId(motoristaId)
                .tipo(Notificacao.Tipo.VIAGEM_CRIADA)
                .titulo("Viagem criada com sucesso")
                .mensagem("Sua viagem de " + origem + " até " + destino + " foi criada!")
                .dadosExtras(dados.toString())
                .build();

        notificacaoRepository.save(notificacao);
        log.info("Notificação processada: viagem criada - motoristaId={}", motoristaId);
    }

    public void processarPassageiroEntrou(Map<String, Object> dados) {
        Long passageiroId = Long.parseLong(dados.get("passageiroId").toString());
        Object viagemId = dados.get("viagemId");

        Notificacao notificacao = Notificacao.builder()
                .destinatarioId(passageiroId)
                .tipo(Notificacao.Tipo.PASSAGEIRO_ENTROU)
                .titulo("Você entrou em uma viagem!")
                .mensagem("Sua reserva na viagem #" + viagemId + " foi confirmada.")
                .dadosExtras(dados.toString())
                .build();

        notificacaoRepository.save(notificacao);
        log.info("Notificação processada: passageiro entrou - passageiroId={}, viagemId={}", passageiroId, viagemId);
    }

    public List<NotificacaoResponseDTO> listarPorDestinatario(Long destinatarioId) {
        return notificacaoRepository.findByDestinatarioIdOrderByCriadoEmDesc(destinatarioId)
                .stream()
                .map(NotificacaoResponseDTO::fromEntity)
                .toList();
    }

    public List<NotificacaoResponseDTO> listarNaoLidas(Long destinatarioId) {
        return notificacaoRepository.findByLidaFalseAndDestinatarioId(destinatarioId)
                .stream()
                .map(NotificacaoResponseDTO::fromEntity)
                .toList();
    }

    public long contarNaoLidas(Long destinatarioId) {
        return notificacaoRepository.countByDestinatarioIdAndLidaFalse(destinatarioId);
    }

    public int marcarComoLidas(List<Long> ids) {
        List<Notificacao> notificacoes = notificacaoRepository.findAllById(ids);
        notificacoes.forEach(n -> n.setLida(true));
        notificacaoRepository.saveAll(notificacoes);
        return notificacoes.size();
    }

    public List<NotificacaoResponseDTO> listarTodas() {
        return notificacaoRepository.findAll()
                .stream()
                .map(NotificacaoResponseDTO::fromEntity)
                .toList();
    }
}
