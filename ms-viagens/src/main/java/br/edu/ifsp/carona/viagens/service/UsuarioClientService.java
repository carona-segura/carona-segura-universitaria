package br.edu.ifsp.carona.viagens.service;

import br.edu.ifsp.carona.viagens.dto.UsuarioClientDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Service
@RequiredArgsConstructor
public class UsuarioClientService {

    private final WebClient.Builder webClientBuilder;

    @Value("${ms.usuarios.url}")
    private String usuariosUrl;

    public UsuarioClientDTO buscarUsuario(Long id) {
        try {
            return webClientBuilder
                    .baseUrl(usuariosUrl)
                    .build()
                    .get()
                    .uri("/api/usuarios/{id}", id)
                    .retrieve()
                    .bodyToMono(UsuarioClientDTO.class)
                    .block();
        } catch (WebClientResponseException e) {
            throw new IllegalArgumentException("Usuário não encontrado: " + id);
        } catch (Exception e) {
            throw new IllegalArgumentException("Usuário não encontrado: " + id);
        }
    }
}
