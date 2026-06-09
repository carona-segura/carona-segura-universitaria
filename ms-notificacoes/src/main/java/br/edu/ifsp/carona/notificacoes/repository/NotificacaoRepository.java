package br.edu.ifsp.carona.notificacoes.repository;

import br.edu.ifsp.carona.notificacoes.entity.Notificacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificacaoRepository extends JpaRepository<Notificacao, Long> {

    List<Notificacao> findByDestinatarioIdOrderByCriadoEmDesc(Long destinatarioId);

    List<Notificacao> findByLidaFalseAndDestinatarioId(Long destinatarioId);

    long countByDestinatarioIdAndLidaFalse(Long destinatarioId);
}
