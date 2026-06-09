package br.edu.ifsp.carona.notificacoes.controller;

import br.edu.ifsp.carona.notificacoes.dto.MarcarLidaDTO;
import br.edu.ifsp.carona.notificacoes.dto.NotificacaoResponseDTO;
import br.edu.ifsp.carona.notificacoes.service.NotificacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notificacoes")
@RequiredArgsConstructor
@Tag(name = "Notificações")
public class NotificacaoController {

    private final NotificacaoService notificacaoService;

    @GetMapping("/usuario/{destinatarioId}")
    @Operation(summary = "Lista todas as notificações de um usuário")
    public ResponseEntity<List<NotificacaoResponseDTO>> listarPorDestinatario(@PathVariable Long destinatarioId) {
        return ResponseEntity.ok(notificacaoService.listarPorDestinatario(destinatarioId));
    }

    @GetMapping("/usuario/{destinatarioId}/nao-lidas")
    @Operation(summary = "Lista notificações não lidas de um usuário")
    public ResponseEntity<List<NotificacaoResponseDTO>> listarNaoLidas(@PathVariable Long destinatarioId) {
        return ResponseEntity.ok(notificacaoService.listarNaoLidas(destinatarioId));
    }

    @GetMapping("/usuario/{destinatarioId}/contar")
    @Operation(summary = "Conta notificações não lidas de um usuário")
    public ResponseEntity<Map<String, Long>> contarNaoLidas(@PathVariable Long destinatarioId) {
        long total = notificacaoService.contarNaoLidas(destinatarioId);
        return ResponseEntity.ok(Map.of("total", total));
    }

    @PatchMapping("/marcar-lidas")
    @Operation(summary = "Marca uma lista de notificações como lidas")
    public ResponseEntity<Map<String, Integer>> marcarComoLidas(@RequestBody MarcarLidaDTO dto) {
        int marcadas = notificacaoService.marcarComoLidas(dto.ids());
        return ResponseEntity.ok(Map.of("marcadas", marcadas));
    }

    @GetMapping
    @Operation(summary = "Lista todas as notificações (admin/debug)")
    public ResponseEntity<List<NotificacaoResponseDTO>> listarTodas() {
        return ResponseEntity.ok(notificacaoService.listarTodas());
    }
}
