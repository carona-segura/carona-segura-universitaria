package br.edu.ifsp.carona.viagens.repository;

import br.edu.ifsp.carona.viagens.entity.Viagem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ViagemRepository extends JpaRepository<Viagem, Long> {

    List<Viagem> findByMotoristaId(Long motoristaId);

    List<Viagem> findByStatus(Viagem.Status status);

    List<Viagem> findByOrigemContainingIgnoreCaseAndDestinoContainingIgnoreCase(String origem, String destino);
}
