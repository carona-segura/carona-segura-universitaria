package br.edu.ifsp.carona.viagens.controller;

import br.edu.ifsp.carona.viagens.dto.*;
import br.edu.ifsp.carona.viagens.service.ViagemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/viagens")
@RequiredArgsConstructor
@Tag(name = "Viagens", description = "Gerenciamento de viagens e caronas universitárias")
public class ViagemController {

    private final ViagemService viagemService;

    @PostMapping
    @Operation(summary = "Criar nova viagem")
    public ResponseEntity<ViagemResponseDTO> criar(@Valid @RequestBody ViagemRequestDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(viagemService.criar(dto));
    }

    @GetMapping
    @Operation(summary = "Listar todas as viagens")
    public ResponseEntity<List<ViagemResponseDTO>> listar() {
        return ResponseEntity.ok(viagemService.listar());
    }

    @GetMapping("/abertas")
    @Operation(summary = "Listar viagens abertas")
    public ResponseEntity<List<ViagemResponseDTO>> listarAbertas() {
        return ResponseEntity.ok(viagemService.listarAbertas());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buscar viagem por ID")
    public ResponseEntity<ViagemResponseDTO> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(viagemService.buscarPorId(id));
    }

    @GetMapping("/motorista/{motoristaId}")
    @Operation(summary = "Listar viagens por motorista")
    public ResponseEntity<List<ViagemResponseDTO>> buscarPorMotorista(@PathVariable Long motoristaId) {
        return ResponseEntity.ok(viagemService.buscarPorMotorista(motoristaId));
    }

    @GetMapping("/buscar")
    @Operation(summary = "Buscar viagens por rota (origem e destino)")
    public ResponseEntity<List<ViagemResponseDTO>> buscarPorRota(
            @RequestParam String origem,
            @RequestParam String destino) {
        return ResponseEntity.ok(viagemService.buscarPorRota(origem, destino));
    }

    @PatchMapping("/{id}/cancelar")
    @Operation(summary = "Cancelar uma viagem")
    public ResponseEntity<ViagemResponseDTO> cancelar(@PathVariable Long id) {
        return ResponseEntity.ok(viagemService.cancelar(id));
    }

    @PostMapping("/{viagemId}/passageiros")
    @Operation(summary = "Entrar em uma viagem como passageiro")
    public ResponseEntity<PassageiroResponseDTO> entrarNaViagem(
            @PathVariable Long viagemId,
            @Valid @RequestBody PassageiroRequestDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(viagemService.entrarNaViagem(viagemId, dto.passageiroId()));
    }

    @GetMapping("/{viagemId}/passageiros")
    @Operation(summary = "Listar passageiros de uma viagem")
    public ResponseEntity<List<PassageiroResponseDTO>> listarPassageiros(@PathVariable Long viagemId) {
        return ResponseEntity.ok(viagemService.listarPassageiros(viagemId));
    }
}
