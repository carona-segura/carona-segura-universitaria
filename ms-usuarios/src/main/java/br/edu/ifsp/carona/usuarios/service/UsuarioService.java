package br.edu.ifsp.carona.usuarios.service;

import br.edu.ifsp.carona.usuarios.config.RabbitMQConfig;
import br.edu.ifsp.carona.usuarios.dto.LoginRequestDTO;
import br.edu.ifsp.carona.usuarios.dto.UsuarioRequestDTO;
import br.edu.ifsp.carona.usuarios.dto.UsuarioResponseDTO;
import br.edu.ifsp.carona.usuarios.entity.Role;
import br.edu.ifsp.carona.usuarios.entity.Usuario;
import br.edu.ifsp.carona.usuarios.repository.UsuarioRepository;
import br.edu.ifsp.carona.usuarios.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RabbitTemplate rabbitTemplate;

    public UsuarioResponseDTO cadastrar(UsuarioRequestDTO dto) {
        if (usuarioRepository.existsByEmail(dto.email())) {
            throw new IllegalArgumentException("E-mail já cadastrado: " + dto.email());
        }

        boolean isMotorista = Boolean.TRUE.equals(dto.motorista());

        Usuario usuario = Usuario.builder()
                .nome(dto.nome())
                .email(dto.email())
                .senha(passwordEncoder.encode(dto.senha()))
                .telefone(dto.telefone())
                .motorista(isMotorista)
                .role(isMotorista ? Role.MOTORISTA : Role.PASSAGEIRO)
                .build();

        usuarioRepository.save(usuario);

        rabbitTemplate.convertAndSend(
                RabbitMQConfig.EXCHANGE,
                RabbitMQConfig.ROUTING_KEY_NOVO_USUARIO,
                Map.of("email", usuario.getEmail(), "nome", usuario.getNome())
        );

        return UsuarioResponseDTO.fromEntity(usuario);
    }

    public String login(LoginRequestDTO dto) {
        Usuario usuario = usuarioRepository.findByEmail(dto.email())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado com e-mail: " + dto.email()));

        if (!passwordEncoder.matches(dto.senha(), usuario.getSenha())) {
            throw new IllegalArgumentException("Senha incorreta");
        }

        return jwtService.gerarToken(usuario);
    }

    public List<UsuarioResponseDTO> listarTodos() {
        return usuarioRepository.findAll().stream()
                .map(UsuarioResponseDTO::fromEntity)
                .toList();
    }

    public UsuarioResponseDTO buscarPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado com id: " + id));
        return UsuarioResponseDTO.fromEntity(usuario);
    }

    public UsuarioResponseDTO atualizar(Long id, UsuarioRequestDTO dto) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado com id: " + id));

        usuario.setNome(dto.nome());
        usuario.setTelefone(dto.telefone());
        usuario.setMotorista(Boolean.TRUE.equals(dto.motorista()));

        usuarioRepository.save(usuario);
        return UsuarioResponseDTO.fromEntity(usuario);
    }

    public void deletar(Long id) {
        if (!usuarioRepository.existsById(id)) {
            throw new IllegalArgumentException("Usuário não encontrado com id: " + id);
        }
        usuarioRepository.deleteById(id);
    }
}
