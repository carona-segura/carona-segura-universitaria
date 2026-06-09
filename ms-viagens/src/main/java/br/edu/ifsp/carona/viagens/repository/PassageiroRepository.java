package br.edu.ifsp.carona.viagens.repository;

import br.edu.ifsp.carona.viagens.entity.Passageiro;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PassageiroRepository extends JpaRepository<Passageiro, Long> {

    List<Passageiro> findByViagemId(Long viagemId);

    boolean existsByViagemIdAndPassageiroId(Long viagemId, Long passageiroId);

    long countByViagemIdAndStatus(Long viagemId, Passageiro.StatusPassageiro status);
}
